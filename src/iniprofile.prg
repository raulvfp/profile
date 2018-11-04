*
*|--------------------------------------------------------------------------
*| iniProFile
*|--------------------------------------------------------------------------
*|
*| Gestión de los archivos .ini
*| Author......: Raúl Jrz (raul.jrz@gmail.com)
*| Created.....: 08.05.2018 - 19:46
*| Purpose.....: Crea un objeto que permite leer y grabar archivos ini.
*|               Permite que los datos sean encriptados con el objeto cipherClass
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS iniProFile AS ajaxRest
*
*-----------------------------------------------------------------------------------*

	PROTECTED fileName &&Name del archivo ini
	fileName = .NULL.

	*----------------------------------------------------------------------------*
	FUNCTION setFileName (tcFileName)
	*----------------------------------------------------------------------------*
		IF PCOUNT()<1 OR VARTYPE(tcFileName)#'C' THEN
			ERROR 10, 'Debe ingresar un nombre correcto para el nombre'
		ENDIF

		IF !FILE(tcFileName) THEN
			ERROR 11, 'No existe el archivo'
		ENDIF
		THIS.fileName = ALLTRIM(tcFileName)
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION getFileName ()
	*----------------------------------------------------------------------------*
		IF VARTYPE(THIS.fileName)#'C' OR LEN(THIS.fileName)<3 THEN
			ERROR 12, 'No se definio el Archivo .ini'
		ENDIF

		RETURN THIS.fileName
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION getValue
	LPARAMETERS tcSection, tcKeyName
	*
	* Created.....: 15.01.18 - 17.07
	* Purpose.....: Leer los archivos de configuracion
	*               Routine for getting a string from user configuration file
	* Parameters..: tcFileName, tcSection, tcKeyName
	*                     tcFileName   the name of the configuration file; full path optional,
	*                                  will use the search path as specified by SET PATH command
	*                                  if not located first in the current directory
	*                     tcSection    the section in the configuration file to retrieve the
	*                                  string from
	*                     tcKeyName    the name of the string text to retrieve
	* Return......: cadena de caracteres con el valor de la clave
	*				string value or null if not found
	* Revisions...: v1.00
	*----------------------------------------------------------------------------*
	*--$raj:2014.03.16: Funcion extraida de MSDOS/fpd26
		PRIVATE fhandle, str_buffer, cReturn, nPos, cError
		cError = NULL
		cReturn= SPACE(1)

		IF FILE(tcFileName)                                && Check if configuration file exists
			fhandle = FOPEN(tcFileName)                    && Open for read only
			=FSEEK(fhandle,0,0)                            && Goto beginning of file
			DO WHILE NOT FEOF(fhandle)                     && Loop to find string header section
				str_buffer = FGETS(fhandle)                && Get string of text from file

				IF ATC(tcSection, str_buffer) > 0          && Test if section header found
					DO WHILE NOT FEOF(fhandle)             && Loop to find string text
						str_buffer = FGETS(fhandle)        && Get string of text from file
						IF ATC(tcKeyName,str_buffer) > 0   && Test if string text found
							nPos = ATC("=",str_buffer) + 1 && Get starting position of return string
							cReturn = SUBSTR(str_buffer,nPos)
							cError  = NULL
							EXIT
						ENDIF
						cReturn = SPACE(1)                 && String not found, set return to null
						IF ATC("[",str_buffer) > 0         && Test if next section encountered
							EXIT                           && Next section, exit loop
						ENDIF
					ENDDO

					cError = NULL
					EXIT
				ENDIF

				cReturn = SPACE(1)                         && String not found, set return to null
				cError  = ' No se encontro la Seccion '
			ENDDO
			=FCLOSE(fhandle)                               && Close file
		ELSE
			cReturn = SPACE(1)                             && File not found, set return to null
			cError  = ' No se encontro el archivo '
		ENDIF

		IF !EMPTY(cError) AND LEN(ALLTRIM(cError))>0 THEN
			* Si encontro algun error lo graba en un archivo con extension .err
			cError  = '#[ERROR]:41 | '+tcFileName+' | '+tcSection+' | '+tcKeyName+' | ';
				+cError
			STRTOFILE(cError, STRTRAN(tcFileName,'.ini','.err'))
		ENDIF
		RETURN ALLTRIM(cReturn)
	ENDFUNC


	*----------------------------------------------------------------------------*
	*
	*  Routine for setting a string in a user configuration file
	*
	*  Return Value:      number of bytes written to file, or 0 if cannot write to file (Note: the
	*                     value returned will be the number of bytes last successfully written and
	*                     not necessarily the number of bytes for the string passed to write;
	*                     therefore, success is determined if number returned is greater than zero.)
	*
	*  Parameters:        file_name    the name of the configuration file; full path optional,
	*                                  will use the search path as specified by SET PATH command
	*                                  if not located first in the current directory
	*                     tcSection    the section in the configuration file to write the
	*                                  string under
	*                     str_name     the name of the string text to write
	*                     str_value    the value of the string text to write (Note: the value
	*                                  does not have to be a string -- can be passed as a string,
	*                                  numeric, or logical.)
	*
	*
	FUNCTION SetProfileString
	PARAMETERS tcFileName, tcSection, str_name, str_value
	*----------------------------------------------------------------------------*
		PRIVATE leFileHandler, str_buffer, leTempHandler, lcTempFile, lnNumBytes, write_section, write_value

		IF FILE(tcFileName) THEN

			write_section = .F.                                   && Set not written flag (section)
			write_value = .F.                                     && Set not written flag (value)
			leFileHandler = FOPEN(tcFileName,12)                         && Open conf file for read/write
			lcTempFile = SYS(2003) + "\temp.ini"                   && Set temp file name for conf file
			leTempHandler = FCREATE(lcTempFile)                          && Create temporary conf file
			DO WHILE NOT FEOF(leFileHandler)                            && Loop to find string header section
				str_buffer = FGETS(leFileHandler)                        && Get line of text from conf file
				lnNumBytes = FPUTS(leTempHandler,str_buffer)              && Write out text name and value

				IF ATC(tcSection,str_buffer) > 0                 && Test if section header found
					write_section = .T.                             && Indicate section header written
					DO WHILE NOT FEOF(leFileHandler)                      && Loop to find string text
						str_buffer = FGETS(leFileHandler)                  && Get string of text from file
						IF ATC(str_name,str_buffer) > 0              && Test if string text found
							lnNumBytes = put_str_value(leTempHandler,str_name,str_value)
							write_value = .T.                         && Indicate conf value written
							EXIT
						ELSE
							IF ATC("[",str_buffer) = 1                && Check for next section
								lnNumBytes = put_str_value(leTempHandler,str_name,str_value)
								write_value = .T.                      && Indicate conf value written
								lnNumBytes=FPUTS(leTempHandler,str_buffer)    && Write out text name and value
								EXIT
							ELSE
								lnNumBytes=FPUTS(leTempHandler,str_buffer)    && Write out text name and value
							ENDIF
						ENDIF
					ENDDO
					IF !write_value                                 && Check if conf value written
						lnNumBytes = put_str_value(leTempHandler,str_name,str_value)
						write_value = .T.                            && Indicate conf value written
					ENDIF
					IF lnNumBytes > 0                                && Check if user text written
						DO WHILE NOT FEOF(leFileHandler)                   && Loop to write remaining file
							str_buffer = FGETS(leFileHandler)               && Get text from conf file
							lnNumBytes = FPUTS(leTempHandler,str_buffer)     && Write text to temp file
						ENDDO
					ENDIF
					EXIT                                            && Exit loop
				ENDIF
			ENDDO
			IF !write_section                                     && Check if sect/conf value written
				str_buffer = "[" + tcSection + "]"
				lnNumBytes=FPUTS(leTempHandler,str_buffer)                && Write out section header text
				IF lnNumBytes > 0
					lnNumBytes = put_str_value(leTempHandler,str_name,str_value)
				ENDIF
			ENDIF
			=FCLOSE(leFileHandler)                                      && Close file
			=FCLOSE(leTempHandler)                                      && Close file
			IF lnNumBytes > 0                                      && Check if user text written
				NDX = ATC(".",tcFileName)                           && Get file name w/o extension
				bak_name = LEFT(tcFileName,NDX) + "BAK"             && Add extension to bak name
				IF FILE(bak_name)                                  && Check if backup exists
					DELETE FILE (bak_name)                          && Delete if exists
				ENDIF
				RENAME (tcFileName) TO (bak_name)
				RENAME (lcTempFile) TO (tcFileName)
			ELSE
				DELETE FILE lcTempFile                              && Not written, del tmp & return
			ENDIF
		ELSE
			leFileHandler = FCREATE(tcFileName)                          && File does not exist, create
			IF leFileHandler > -1                                       && Check for file creation error
				str_buffer = "[" + tcSection + "]"
				lnNumBytes=FPUTS(leFileHandler,str_buffer)                && Write out section header text
				IF lnNumBytes > 0
					lnNumBytes = put_str_value(leFileHandler,str_name,str_value)
					=FCLOSE(leFileHandler)                                && Close file
				ENDIF
			ELSE
				lnNumBytes = 0
			ENDIF
		ENDIF
		RETURN lnNumBytes
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	*
	*  Routine for writing the user string value to the configuration file based on data type
	*
	FUNCTION put_str_value
	PARAMETERS teHandle, tcKeyName, tcKeyValue
	* Parameters..: 
	*               teHaandle    the handle of the "ini" file
	*               tcKeyName    the name the key for writing in the file
	*               tcKeyValue   the value of the key
	* Return......: 
	*               lnNum_Bytes  the position actul in bytes
	*----------------------------------------------------------------------------*
		PRIVATE lcStr_Buffer, lnNum_Bytes

		DO CASE                                                       && Determine data type to write
			CASE TYPE('tcKeyValue') = "C"                             && User string is of char type
				lcStr_Buffer= tcKeyName + "=" + tcKeyValue
				lnNum_Bytes = FPUTS(teHandle,lcStr_Buffer)            && Write out text name and value
			CASE TYPE('tcKeyValue') = "N"                             && User string is numeric
				lcStr_Buffer= tcKeyName + "=" + STR(tcKeyValue)
				lnNum_Bytes = FPUTS(teHandle,lcStr_Buffer)            && Write out text name and value
			CASE TYPE('tcKeyValue') = "D"                             && User string is date
				lcStr_Buffer= tcKeyName + "=" + DTOC(tcKeyValue)
				lnNum_Bytes = FPUTS(teHandle,lcStr_Buffer)            && Write out text name and value
			CASE TYPE('tcKeyValue') = "L"                             && User string is logical
				IF tcKeyValue
					lcStr_Buffer = tcKeyName + "=TRUE"
				ELSE
					lcStr_Buffer = tcKeyName + "=FALSE"
				ENDIF
				lnNum_Bytes=FPUTS(teHandle,lcStr_Buffer)              && Write out text name and value
			OTHERWISE                                                 && Data type unknown
				lnNum_Bytes = 0
		ENDCASE
		RETURN lnNum_Bytes
	ENDFUNC
	*
ENDDEFINE
