# Profile

* support: raul.jrz@gmail.com
* url: [http://rauljrz.github.io/](http://rauljrz.github.io)
* Comentarios en http://rinconfox.com

**Do you like this project? Support it by donating**

- <a class="bmc-button" target="_blank" href="https://www.buymeacoffee.com/rauljrz"><img src="https://www.buymeacoffee.com/assets/img/BMC-btn-logo.svg" alt="Buy me a coffee"><span style="margin-left:5px">Buy me a coffee</span></a>
- ![Paypal](https://raw.githubusercontent.com/reek/anti-adblock-killer/gh-pages/images/paypal.png) Paypal: [Si te sirvio, invitame un café o una cerveza](https://www.paypal.me/rauljrz)
- ![btc](https://camo.githubusercontent.com/4bc31b03fc4026aa2f14e09c25c09b81e06d5e71/687474703a2f2f7777772e6d6f6e747265616c626974636f696e2e636f6d2f696d672f66617669636f6e2e69636f) Bitcoin:

## Dependencies
https://github.com/raulvfp/catchException
    Para el control de las excepciones.

## Installation
```
git clone https://github.com/raulvfp/profile.git profile
```

## Auxiliary methods:
- isSuccess()  : Devuelve .T. si tuvo exito la última operación, de lo contrario .F.
- isError()    : Devuelve .T. si tuvo error la última operación, de lo contrario .F.
- getMsgError(): Si la última operación dio error, contiene el Mensaje de Error, de lo contrario .null.
- getFileName(): Devuelve el nombre del archivo profile con el cual se esta trabajando.

## Main Methods:

- [**delete**](#delete)(cSection AS CHARACTER, cKey AS CHARACTER)

	_Elimina un Clave (cKey) de una Sección (cSection) determinada._
    
- [**getValue**](#getvalue)(cSection AS CHARACTER, cKey AS CHARACTER)

	_Devuelve el valor de una Clave (cKey) de una Seccón (cSection) determinada._
    
- [**read**](#read)(cFileName AS CHARACTER)

	_Lee el contenido de un archivo Profile (cFileName) y lo carga en un objeto._
    
- [**save**](#save)()

	_Guarda las modificaciones en disco._
    
- [**saveTo**](#saveto)(cNewFile AS CHARACTER)

	_Guarda los datos en un nuevo archivo Profile(cFileName)._
    
- [**setValue**](#setvalue)(cSection AS CHARACTER, cKey AS CHARACTER, eValue)

	_Asigna un valor (eValue) en una clave (cKey) de una seccón (cSection) determinada._

## Usage:
- **.delete()**
    + **Parameters**:

		. cSection: _La Seccion en donde se buscara la clave a borrar_.
	
		. cKey: _La Clave que se busca borrar._
        
    + **Return Value**: Si tuvo exito una Cadena de Caracteres con la clave y su valor, de lo contrario _.null._.

	*Example:*

```
	loProfile = CREATEOBJECT('profile')
	IF loProfile.Read('config.ini') THEN
    	ASSERT !ISNULL(loProfile.Delete("Data Store", "BackEnd")) ;
        		MESSAGE "Atención, no se pudo eliminar la clave 'BackEnd'!"
	ENDIF
```


- **.getValue()**
	+ **Parameters**:
	
		. cSection: _Es la sección en donde se buscará la clave._
		
		. cKey: _Es la clave a buscar._

	+ **Return Value**: Si existe, devuelve una cadena, de lo contrario _.null._.

	*Example:*

```
	loProfile = CREATEOBJECT('profile')
	IF loProfile.Read('config.ini') THEN
		? loProfile.getValue('Data Store', 'BackEnd')
	ENDIF
```


- **.Read()**
    + **Parameters**: 
    
    	. cFileName: _Es el Nombre del Archivo a Leer._
        
    + **Return Value**: Si tuvo exito True, de lo contrario False.

	*Example:*

```
	loProfile = CREATEOBJECT('profile')
	IF loProfile.Read('config.ini') THEN
		&&Archivo config.ini fue leido y cargado con exito.
	ENDIF
```


- **.Save()**
    + **Parameters**:
        
    + **Return Value**: Si tuvo exito True, de lo contrario False.

	*Example:*

```
	loProfile = CREATEOBJECT('profile')
	IF loProfile.Read('config.ini') THEN
		ASSERT loProfile.Save() ;
        		MESSAGE "Atención, no se pudo guardar el archivo"
	ENDIF
```


- **.SaveTo()**
    + **Parameters**:
    
    	. cFileName: _El nombre del nuevo archivo Profile._
        
    + **Return Value**: Si tuvo exito True, de lo contrario False.

	*Example:*

```
	loProfile = CREATEOBJECT('profile')
	IF loProfile.Read('config.ini') THEN
		ASSERT loProfile.SaveTo('nuevoarchivo.ini') ;
        		MESSAGE "Atención, no se pudo guardar en el nuevo archivo"
	ENDIF
```


- **.SetValue()**
	+ **Parameters**:
	
		. cSection : _Es la sección en donde se agrega la clave._
		
		. cKey     : _Es la clave._
		
		. eValue   : _El valor que se le cargarrá a la clave._

	+ **Return Value**: Si tuvo exito True, de lo contrario False

	  *Example:*

```
	loProfile = CREATEOBJECT('profile')
	IF loProfile.Read('config.ini') THEN
		ASSERT loProfile.setValue('Data Store', 'BackEnd', 'MySQL') ;
        		MESSAGE 'Error, no se pudo asignar el valor a la clave'
	ENDIF
```


http://rinconfox.com

---

**Do you like this project? Support it by donating**

- <a class="bmc-button" target="_blank" href="https://www.buymeacoffee.com/rauljrz"><img src="https://www.buymeacoffee.com/assets/img/BMC-btn-logo.svg" alt="Buy me a coffee"><span style="margin-left:5px">Buy me a coffee</span></a>
- ![Paypal](https://raw.githubusercontent.com/reek/anti-adblock-killer/gh-pages/images/paypal.png) Paypal: [Si te sirvio, invitame un café o una cerveza](https://www.paypal.me/rauljrz)
- ![btc](https://camo.githubusercontent.com/4bc31b03fc4026aa2f14e09c25c09b81e06d5e71/687474703a2f2f7777772e6d6f6e747265616c626974636f696e2e636f6d2f696d672f66617669636f6e2e69636f) Bitcoin:
