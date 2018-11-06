*
*|--------------------------------------------------------------------------
*| profile
*|--------------------------------------------------------------------------
*|
*| Clase para administrar el contenido de una archivo profile (.ini)
*| Author......: Raul Jrz (raul.jrz@gmail.com)
*|               Freelancer in http://pph.me/rauljrz
*| Created.....: 2018.10.26 - 15.50
*| Purpose.....: ini file manager
*| Web site....: http://rauljrz.github.io
*|
*| Support by..: http://rinconfox.com
*| 
*| Revisions...: v1.00
*|
*|----------------------------------------------------------------------------
*| Do you like this project? Support it by donating
*|  - Buy me a coffee or Beer - 
*|    https://www.buymeacoffee.com/rauljrz
*|    https://www.paypal.me/rauljrz
*|----------------------------------------------------------------------------
*| LICENSE:
*|----------------------------------------------------------------------------
*| "THE BEER-WARE LICENSE" (Revision 42):
*| <raul.jrz@gmail.com> wrote this file. As long as you retain this notice you
*| can do whatever you want with this stuff. If we meet some day, and you think
*| this stuff is worth it, you can buy me a beer in return or a Virtual Coffee
*| in https://www.buymeacoffee.com/rauljrz
*|----------------------------------------------------------------------------
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS profile AS Custom
*
*-----------------------------------------------------------------------------------*
	bRelanzarThrow = .T. &&Relanza la excepcion al nivel superior

	PROTECTED fileName &&name of the ini file
	fileName = ''

	PROTECTED msgError &&registra los mensajes de error
	msgError = ''
	
	PROTECTED oContent
	oContent = null
	
	*----------------------------------------------------------------------------*
	FUNCTION catchException()
	* Control de las excepciones/errores
	*----------------------------------------------------------------------------*
		IF RIGHT(SYS(16,0),4) = ".EXE" THEN
			NEWOBJECT('catchException','catchException.prg','', THIS.bRelanzarThrow)
		ELSE
			CREATEOBJECT('catchException', THIS.bRelanzarThrow)
		ENDIF
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION isError()
	* Indica si existio un error en la ultima operación realizada
	*----------------------------------------------------------------------------*
		RETURN !THIS.isSuccess()
	ENDFUNC
	
	*----------------------------------------------------------------------------*
	FUNCTION isSuccess()
	* Indica fue exitosa la ultima acción
	*----------------------------------------------------------------------------*
		RETURN EMPTY(THIS.msgError)
	ENDFUNC
	
	*----------------------------------------------------------------------------*
	FUNCTION getMsgError()
	* Devuelve la leyenda del Error de la ultima acción.
	*----------------------------------------------------------------------------*
		RETURN THIS.msgError
	ENDFUNC
	*			
	*----------------------------------------------------------------------------*
	FUNCTION getFileName()
	* Devuelve el nombre del archivo profile con el cual se esta trabajando.
	*----------------------------------------------------------------------------*
		RETURN THIS.fileName
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION delete(tcSection AS CHARACTER, tcKey AS CHARACTER)
	* Borra una clave determinada, o toda una sección si no se especifica una clave
	*----------------------------------------------------------------------------*
		LOCAL leReturn
		leReturn = null
		
		TRY
			tcSection = THIS.formatProperty(tcSection)
			loSection = THIS.checkExist(THIS.oContent, tcSection)
			IF !ISNULL(loSection) THEN
				*- Existe la sección
				IF PCOUNT()=1 AND VARTYPE(tckey)#'C' THEN
					*- Borro toda la sección
					leReturn = tcSection
					REMOVEPROPERTY(THIS.oContent, tcSection)
				ELSE
					*- Borro una clave
					tckey = THIS.formatProperty(tckey)			
					leKey = THIS.checkExist(loSection, tckey)
					IF !ISNULL(leKey) THEN
						*- Existe y borro la clave
						leReturn = tcKey + ' = '+leKey
						REMOVEPROPERTY(loSection, tcKey)
					ENDIF
				ENDIF
			ENDIF
		CATCH TO loEx
			THIS.catchException()
		ENDTRY
		RETURN leReturn
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION getValue(tcSection AS CHARACTER, tcKey AS CHARACTER)
	* Devuelve el valor de una clave si existe en una section determinada.
	* Si no existe, devuelve null
	*----------------------------------------------------------------------------*
		LOCAL leReturn

		leReturn= THIS.checkExist(;
							THIS.checkExist(THIS.oContent, tcSection);
							, tcKey;
						)
		
		IF ISNULL(leReturn) THEN
			THIS.msgError = 'Not Found key '+tcKey+' in section '+tcSection
		ENDIF
		RETURN leReturn
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION read(tcFileName AS CHARACTER)
	* Read ini File and build object with the data
	*----------------------------------------------------------------------------*
		LOCAL lcSection, lcLine, lnInd, lnKey
		STORE '' TO lcSection, lcLine
		
		TRY
			THIS.setFileName(tcFileName)
			FOR lnInd = 1 TO ALINES(laContent, FILETOSTR(THIS.getFileName()), 1+4)        &&Levanto el archivo en un array
				lcLine = ALLTRIM(laContent[lnInd])
				IF SUBSTR(lcLine,1,1)='#' THEN
					*- Es un comentario
					LOOP
				ENDIF
				
				IF '['$lcLine THEN                                            &&Es un título de sección
					lcSection = THIS.formatProperty(lcLine)                   &&Si tiene corchetes los quito
					IF LEN(lcSection)!=LEN(CHRTRAN(lcSection,'¬|°/!"#$%()=?¡¿´+¨*}][{-.:,;^`~\','')) THEN
						lcSection = ''
						LOOP
					ENDIF

					THIS.pushSection(lcSection)                               &&Creo la nueva sección
				ELSE
					IF !EMPTY(lcSection) THEN                                 &&No es un título ni comentario, puede ser una clave
						lnKey = ALINES(laKey,lcLine,4+1,'=')                  &&Intento separar entre clave y valor
						IF !EMPTY(lcSection) AND lnKey=2 AND !EMPTY(laKey[1]) THEN
							THIS.setValue(lcSection, laKey[1], laKey[2])      &&Agrego la nueva clave con el valor
						ENDIF
					ENDIF
				ENDIF &&'['$lcLine THEN
			ENDFOR

		CATCH TO loEx
			THIS.msgError = loEx.Message
			THIS.catchException()
		ENDTRY
		RETURN THIS.isSuccess()  
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION save()
	* Guarda el profile en el archivo de origen, creando un .bak si ya existe
	*----------------------------------------------------------------------------*
		THIS.saveTo(THIS.getFileName())
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION saveTo(tcNewFile AS CHARACTER)
	* Guarda el profile en un archivo
	*----------------------------------------------------------------------------*
		LOCAL loContent, LFCR, lcContent
		LFCR = CHR(13)+CHR(10)
		lcContent = ''                &&Es el contenido del nuevo archivo ini de salida
		loContent = THIS.oContent
		
		TRY
			IF FILE(tcNewFile) THEN
				COPY FILE (tcNewFile) TO (FORCEEXT(tcNewFile, 'bak'))
			ENDIF
			
			IF VARTYPE(loContent)='O' THEN
				FOR lnInd=1 TO AMEMBERS(laContent, loContent)
					lcSection = laContent[lnInd]
					
					loSection = loContent.&lcSection
					
					FOR lnJnd=1 TO AMEMBERS(laSection, loSection)
						IF lnJnd=1 THEN &&Pongo el titulo de la section
							lcContent = lcContent + '['+PROPER(CHRTRAN(lcSection,'_',' '))+']'+LFCR
						ENDIF
						
						lcKey = laSection[lnJnd]
						loKey = loSection.&lcKey
						lcContent = lcContent +;
									PROPER(CHRTRAN(lcKey,'_',' ')) +' = '+ loSection.&lcKey +LFCR
					ENDFOR
					lcContent = lcContent +LFCR 
				ENDFOR
			ENDIF
			
			IF !EMPTY(lcContent) THEN
				STRTOFILE(lcContent, tcNewFile)
			ENDIF
		
		CATCH TO loEx
			THIS.catchException()
		ENDTRY
		RETURN THIS.isSuccess()
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION setValue(tcSection AS CHARACTER, tcKey AS CHARACTER, teValue)
	* Agrega una valor a una clave dada en una sección determinada de una profile
	*----------------------------------------------------------------------------*
		TRY
			WITH THIS
				tcSection = .formatProperty(tcSection)
				tcKey     = .formatProperty(tcKey)
				teValue   = TRANSFORM(teValue)
				
				.pushSection(tcSection)                           &&Agrego la seccion si no existe
				
				loSection  = .checkExist(.oContent, tcSection)    &&Traigo la seccion para editar
				leValueNow = .checkExist(loSection, tcKey)        &&Busco la clave en la seccion
			ENDWITH 
			
			IF ISNULL(leValueNow) THEN                            &&Si no existe el valor, lo agrego
				ADDPROPERTY(loSection, tcKey, teValue)
			ENDIF
				
			loSection.&tcKey = teValue

		CATCH TO loEx
			THIS.msgError = loEx.Message
			THIS.catchException()
		ENDTRY
		RETURN THIS.isSuccess()
  	ENDFUNC
  	*
	*----------------------------------------------------------------------------*
	PROTECTED FUNCTION initAction()
	* Prepara todo, blanqueando para inicializar las acciones
	*----------------------------------------------------------------------------*
		THIS.msgError = ''
		THIS.oContent = null
		RETURN THIS.isSuccess()
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	PROTECTED FUNCTION setFileName(tcFileName)
	* 
	*----------------------------------------------------------------------------*
		THIS.initAction()
		THIS.fileName = ''
		
		IF PCOUNT()<1 OR VARTYPE(tcFileName)#'C' THEN
			THIS.msgError = 'Debe ingresar un nombre correcto para el nombre'
		ELSE	
			IF !FILE(tcFileName) THEN
				THIS.msgError = 'File Not Found'
			ELSE
				THIS.fileName = ALLTRIM(tcFileName)
			ENDIF
		ENDIF
		RETURN THIS.isSuccess()
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	PROTECTED FUNCTION checkExist(toObject, tcProperty)
	* Verifica si existe una propiedad dada en el objeto
	*----------------------------------------------------------------------------*
		tcProperty = THIS.formatProperty(tcProperty)
		IF VARTYPE(toObject)='O' AND PEMSTATUS(toObject, tcProperty, 5) THEN
			RETURN toObject.&tcProperty
		ENDIF
		RETURN null
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	PROTECTED FUNCTION formatProperty(teProperty)
	* Formatea la propiedad para que pueda ser manejada por vfox
	*----------------------------------------------------------------------------*
		RETURN LOWER(STRTRAN(ALLTRIM(CHRTRAN(TRANSFORM(teProperty),'[]',' ')),' ','_'))
	ENDFUNC
	* 
	*----------------------------------------------------------------------------*
	PROTECTED FUNCTION pushSection(tcNewSection)
	* Agrega una nueva section si no existe
	*----------------------------------------------------------------------------*
		TRY
			IF VARTYPE(THIS.oContent)#'O' THEN
				THIS.oContent = CREATEOBJECT('EMPTY')
			ENDIF
			IF ISNULL(THIS.checkExist(THIS.oContent, tcNewSection)) THEN
				ADDPROPERTY(THIS.oContent, tcNewSection, CREATEOBJECT('EMPTY'))
			ENDIF
		CATCH TO loEx
			THIS.catchException()
		ENDTRY
	ENDFUNC
	*
ENDDEFINE