*/
* @since:  1.0
*
* @author: Raúl Juárez <raul.jrz@gmail.com>
* @date: 26.10.2018 - 00:58
*/
DEFINE CLASS test_profile AS FxuTestCase OF FxuTestCase.prg
*----------------------------------------------------------------------

	#IF .F.
		LOCAL THIS AS test_profile OF test_profile.prg
	#ENDIF
	oObject      = ''  &&Este es el objecto que va a ser evaluado
	oldPath      = ''
	oldProcedure = ''
	oldDefault   = ''
	
	textoSinEncriptar =''

	*--------------------------------------------------------------------
	FUNCTION SETUP
	* Configuración base de todos los Test de esta clase
	*--------------------------------------------------------------------
		*SET PATH TO pathraizdelprojecto
		THIS.oldPath     =SET('PATH')
		THIS.oldProcedure=SET('PROCEDURE')
		THIS.oldDefault  =SET('DEFAULT')
		*THIS.MessageOut('Procedures: '+SET("PROCEDURE"))
		*THIS.MessageOut('Path......: '+SET("PATH"))
		*THIS.MessageOut('Default...: '+SET("DEFAULT"))
		*THIS.MessageOut('============================================================')

		SET PROCEDURE TO src\profile.prg ADDITIVE
		SET PROCEDURE TO ..\cipher\src\cipher ADDITIVE
		SET PROCEDURE TO ..\catchException\src\catchException ADDITIVE
		SET PATH TO (THIS.oldPath +";"+ADDBS(SYS(5)+CURDIR())+'src')
		THIS.MessageOut('Procedures:  '+STRTRAN(SET("PROCEDURE"),",",CHR(13)+SPACE(12)))
		THIS.MessageOut('Path......: '+STRTRAN(SET("PATH")     ,";",CHR(13)+SPACE(12)))
		THIS.MessageOut('Default...: '+SET("DEFAULT"))
		THIS.MessageOut('============================================================')
		THIS.MessageOut('')
		THIS.oObject = CREATEOBJECT('profile')

	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION MessageError()
	* Si Existe algun error lo muestra
	*--------------------------------------------------------------------
		THIS.MessageOut('==========')
		THIS.MessageOut('Error: ' + THIS.oObject.getMsgError())
		THIS.MessageOut('==========')
	ENDFUNC
	
	*---------------------------------------------------------------------
	FUNCTION testExisteObjecto()
	* Verifica la existencia del objecto...
	*---------------------------------------------------------------------
		THIS.AssertNotNull('No existe el objecto',THIS.oObject)
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION TearDown
	* Restaura el estado anterior del ambiente de desarrollo
	*--------------------------------------------------------------------
		THIS.MessageError()
		
		SET PATH TO      (THIS.oldPath)
		SET PROCEDURE TO (THIS.oldProcedure)
		SET DEFAULT TO   (THIS.oldDefault)
	ENDFUNC

	*---------------------------------------------------------------------
	FUNCTION test_CreoUnNuevoProfileDesdeCero()
	* 
	*---------------------------------------------------------------------
		LOCAL lcProfile, lcSection, lcKey, lcExpected
		lcSection = 'Primera Seccion'
		lcKey     = 'Clave 1'
		lcProfile = 'nuevo.ini'
		lcExpected= 'datos clave 1'
		WITH THIS
			IF FILE(lcProfile) THEN
				DELETE FILE (lcProfile)
			ENDIF
			.AssertFalse(FILE(lcProfile),'ojo, ya existe el archivo')
			.oObject.setValue(lcSection, lcKey, lcExpected)
			.oObject.saveTo(lcProfile)
			
			.AssertTrue(FILE(lcProfile),'ojo, Deberia existir el archivo')
			.AssertTrue(.oObject.read(lcProfile),'OJO, Problemas al leer el archivo')
			
			lcReal = .oObject.getValue(lcSection, lcKey)
			.MessageOut(lcReal)
			.AssertEquals(lcExpected, lcReal, 'Ojo! Se esperaba->: '+lcExpected)
		ENDWITH
	ENDFUNC
	
	*---------------------------------------------------------------------
	FUNCTION test_Read_CheckValueSection_ok()
	* 
	*---------------------------------------------------------------------
		LOCAL lcExpected, lcReal
		lcExpected = 'MYSQL'
		*- Arrange
		WITH THIS
			.AssertTrue(.oObject.read('readinifile.ini'),'OJO, Problemas al leer el archivo')
		*- Act
			lcReal = .oObject.getValue('Data Store','BackEnd')
		*- Assert	
			.MessageOut(lcReal)
			.MessageOut(.oObject.getMsgError())
			.AssertEquals(lcExpected, lcReal, 'Ojo! Se esperaba->: '+lcExpected)
		ENDWITH
	ENDFUNC

	*---------------------------------------------------------------------
	FUNCTION test_Read_CheckValueSection_error()
	* 
	*---------------------------------------------------------------------
		LOCAL lcExpected, lcReal
		lcExpected = .NULL.
		*- Arrange
		WITH THIS
			.AssertTrue(.oObject.read('readinifile.ini'),'OJO, Problemas al leer el archivo')
		*- Act
			lcReal = .oObject.getValue('NOEXISTE','BackEnd')
		*- Assert	
			.MessageOut(lcReal)
			.MessageOut(.oObject.getMsgError())
			.AssertEquals(lcExpected, lcReal, 'Ojo! Se esperaba->: '+TRANSFORM(lcExpected))
			.AssertTrue(.oObject.isError(),'Ojo! deberia devolver TRUE ya que existe un error')
		ENDWITH
	ENDFUNC
	
	*---------------------------------------------------------------------
	FUNCTION test_setValue_ExisteSection_ExisteKey()
	* 
	*---------------------------------------------------------------------
		LOCAL lcExpected, lcReal, lcSection, lcKey
		lcSection  = 'Data Store'  &&Existe esta seccion
		lcKey      = 'BackEnd'     &&NO existe esta clave
		lcExpected = 'cambiado'
		*- Arrange
		WITH THIS
			.AssertTrue(.oObject.read('readinifile.ini'),'OJO, Problemas al leer el archivo')
		*- Act
			.oObject.setValue('Data Store','BackEnd', 'cambiado')
			lcReal = TRANSFORM(.oObject.getValue(lcSection, lcKey))
		*- Assert
			.AssertEquals(lcExpected, lcReal, 'Ojo! Se esperaba->: '+TRANSFORM(lcExpected))
			.MessageOut(TRANSFORM(lcReal))
			.MessageOut(.oObject.getMsgError())
			.AssertTrue(.oObject.isSuccess(),'Ojo! deberia devolver TRUE ya que existe un error')
		ENDWITH
	ENDFUNC

	*---------------------------------------------------------------------
	FUNCTION test_setValue_ExisteSection_NO_ExisteKey()
	* 
	*---------------------------------------------------------------------
		LOCAL lcExpected, lcReal, lcSection, lcKey
		lcSection  = 'Data Store'  &&Existe esta seccion
		lcKey      = 'NOEXISTEKEY' &&NO existe esta clave
		lcExpected = 'NuevoValor'
		*- Arrange
		WITH THIS
			.AssertTrue(.oObject.read('readinifile.ini'),'OJO, Problemas al leer el archivo')
		*- Act
			.oObject.setValue(lcSection, lcKey, lcExpected)
			lcReal = TRANSFORM(.oObject.getValue(lcSection, lcKey))
		*- Assert	
			.AssertEquals(lcExpected, lcReal, 'Ojo! Se esperaba->: '+TRANSFORM(lcExpected))
			.MessageOut(TRANSFORM(lcReal))
			.MessageOut(.oObject.getMsgError())
			.AssertTrue(.oObject.isSuccess(),'Ojo! deberia devolver TRUE ya que existe un error')
		ENDWITH
	ENDFUNC
	
	*---------------------------------------------------------------------
	FUNCTION test_setValue_NO_ExisteSection_NO_ExisteKey()
	* 
	*---------------------------------------------------------------------
		LOCAL lcExpected, lcReal, lcSection, lcKey
		lcSection  = 'NoExisteSection'  &&Existe esta seccion
		lcKey      = 'NOEXISTEKEY' &&NO existe esta clave
		lcExpected = 'NuevoValor'
		*- Arrange
		WITH THIS
			.AssertTrue(.oObject.read('readinifile.ini'),'OJO, Problemas al leer el archivo')
		*- Act
			.oObject.setValue(lcSection, lcKey, lcExpected)
			lcReal = TRANSFORM(.oObject.getValue(lcSection, lcKey))
		*- Assert	
			.AssertEquals(lcExpected, lcReal, 'Ojo! Se esperaba->: '+TRANSFORM(lcExpected))
			.MessageOut(TRANSFORM(lcReal))
			.MessageOut(.oObject.getMsgError())
			.AssertTrue(.oObject.isSuccess(),'Ojo! deberia devolver TRUE ya que existe un error')
		ENDWITH
	ENDFUNC

	*---------------------------------------------------------------------
	FUNCTION test_SaveToFile()
	* 
	*---------------------------------------------------------------------
		LOCAL lcNewProfile
		lcNewProfile = 'newprofile.ini'
		*- Arrange
		WITH THIS
			IF FILE(lcNewProfile) THEN
				DELETE FILE (lcNewProfile)
			ENDIF
			.AssertTrue(.oObject.read('readinifile.ini'),'OJO, Problemas al leer el archivo')
			
		*- Act
			lcReal = TRANSFORM(.oObject.saveTo(lcNewProfile))
			
		*- Assert	
			.AssertTrue(FILE(lcNewProfile), 'Ojo! No se encuentra el nuevo archivo: '+lcNewProfile)
			.MessageOut(TRANSFORM(lcReal))
			.MessageOut(.oObject.getMsgError())
			.AssertTrue(.oObject.isSuccess(),'Ojo! deberia devolver TRUE ya que existe un error')
		ENDWITH
	ENDFUNC

	*---------------------------------------------------------------------
	FUNCTION test_Save()
	* 
	*---------------------------------------------------------------------
		LOCAL lcFileBak
		lcFileBak = 'readinifile.bak'
		*- Arrange
		WITH THIS
			IF FILE(lcFileBak) THEN
				DELETE FILE (lcFileBak)
			ENDIF
			.AssertTrue(.oObject.read('readinifile.ini'),'OJO, Problemas al leer el archivo')
			
		*- Act
			lcReal = TRANSFORM(.oObject.save())
			
		*- Assert	
			.AssertTrue(FILE(lcFileBak), 'Ojo! No se encuentra el nuevo archivo: '+lcFileBak)
			.MessageOut(TRANSFORM(lcReal))
			.MessageOut(.oObject.getMsgError())
			.AssertTrue(.oObject.isSuccess(),'Ojo! deberia devolver TRUE ya que existe un error')
		ENDWITH
		
	*---------------------------------------------------------------------
	FUNCTION test_delete_key()
	* 
	*---------------------------------------------------------------------
		LOCAL lcExpected, lcReal, lcSection, lcKey
		lcSection  = 'Data Store'  &&Existe esta seccion
		lcKey      = 'BackEnd'     &&NO existe esta clave

		*- Arrange
		WITH THIS
			.AssertTrue(.oObject.read('readinifile.ini'),'OJO, Problemas al leer el archivo')
			
		*- Act
			lcReal = TRANSFORM(.oObject.delete(lcSection))
			
		*- Assert	
		*	.AssertTrue(FILE(lcFileBak), 'Ojo! No se encuentra el nuevo archivo: '+lcFileBak)
			.MessageOut(TRANSFORM(lcReal))
			.oObject.save()
			.MessageOut(.oObject.getMsgError())
			.AssertTrue(.oObject.isSuccess(),'Ojo! deberia devolver TRUE ya que existe un error')
		ENDWITH	
	ENDFUNC
ENDDEFINE
*----------------------------------------------------------------------
* The three base class methods to call from your test methods are:
*
* THIS.AssertTrue	    (<Expression>, "Failure message")
* THIS.AssertEquals	    (<ExpectedValue>, <Expression>, "Failure message")
* THIS.AssertNotNull	(<Expression>, "Failure message")
* THIS.MessageOut       (<Expression>)
*
* Test methods (through their assertions) either pass or fail.
*----------------------------------------------------------------------

* AssertNotNullOrEmpty() example.
*------------------------------
*FUNCTION TestObjectWasCreated
*   THIS.AssertNotNullOrEmpty(THIS.oObjectToBeTested, "Test Object was not created")
*ENDFUNC
