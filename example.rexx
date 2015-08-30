#!/usr/local/regina-rexx/bin/rexx

/*                                                                                */
/* USAGE INFORMATION:                                                             */
/* As you can see this text, you obviously have opened the file in a text editor. */
/*                                                                                */
/* If you would like to *run* this example rather than *read* it, you             */
/* should open Terminal.app, drag this document's icon onto the terminal          */
/* window, bring Terminal.app to the foreground (if necessary) and hit return.    */
/*                                                                                */
/* THIS REQUIRES YOU HAVE INSTALLED REXX / REGINA AND THAT THE PATH               */
/* MATCHES THE FIRST LINE IN THIS SCRIPT. PLEASE CHANGE THE PATH, IF              */
/* NEEDED                                                                         */


/* For REXX make the Pashua input file by making the input Rexx comments    */
/* then use the built in function SOURCELINE to parse the data              */
/* and create the file. That way the Pashua commands exist within           */
/* the Rexx source file. Commands are between START_PASHUA_INPUT: and       */
/* END_PASHUA_INPUT: labels                                                 */

/* Find the application if we can */
currentDirectory = pwd()||"/"
PARSE SOURCE . . sourcePath
sourcePath = dirname("'"||sourcePath||"'")||"/" /* Quoting needed when spaces in path */
bundlepath="Pashua.app/Contents/MacOS/Pashua";
loc.1 = sourcePath||"Pashua"          /* directory containing source, embedded in *.app */
loc.2 = sourcePath||bundlepath        /* directory containing source */
loc.3 = currentDirectory||bundlepath  /* current directory */
loc.4 = "/Applications/"||bundlepath  /* try some of the usual suspects */
loc.5 = "~/Applications/"||bundlepath
pashuaPath = "NOT FOUND"
numLocs = 5

DO i = 1 to numLocs
if(fileExists(loc.i) == 0)
then DO
     pashuaPath = loc.i
     LEAVE i
     END
END

if(pashuaPath == "NOT FOUND")
then DO
     say "Can't find Pashua Application"
     EXIT(1)
     END

/* create a path to the ApplIcon file based on the Pashua.app we are currently using */
/* The Pashua package is distributed with a static link to Pashua.app in the Examples*/
/* directory so strip that off if it exists and create a path to the .icon file      */
iconPath = CHANGESTR("/MacOS/Pashua",pashuaPath, "")||"/Resources/AppIcon.icns"

/* Create a tempfile that is guaranteed to be unqiue */
"/usr/bin/mktemp /tmp/Pashua_XXXXXXXXXX" ' | rxqueue'
IF QUEUED() == 0
THEN DO
     say "mktemp failed - Unable to create temp file for Pashua input"
     EXIT(2)
     END
parse pull fn

/* create a file for Pashua to read */
i = 1;
DO UNTIL (SOURCELINE(i) == "START_PASHUA_INPUT:")
	i = i + 1;
    END;

/* strip the comment delimiters from the pashua input */
DO WHILE (SOURCELINE(i + 1) \= "END_PASHUA_INPUT:")
	i = i + 1;
	line = SOURCELINE(i);
	PARSE var line . body ' */' .
	CALL LINEOUT fn, body;
    END;
/* Dynamically insert the icon path (difficult to hard code this one)*/
CALL LINEOUT fn, "img.path =  "||iconPath

/* OK let Pashua do it's thing */
"'"pashuapath||"' "' 'fn ' | rxqueue'

/* Remove the temp file */
'rm 'fn

if(queued() == 0)
then DO
	say "User quit Pashua"
	EXIT(3)
    END

/* peel the results from the stdout queue */
numReturnedVars = 0
DO WHILE QUEUED() \= 0
	parse pull data
	parse var data nameString '=' is
	if((nameString == "cb") & (is == 1))
	then DO
			say "CANCEL button pressed"
			EXIT(4)
		 END
	numReturnedVars = numReturnedVars + 1
	returnedVar.numReturnedVars = nameString
	IF(LENGTH(is) \= 0)
	THEN INTERPRET nameString||'='||'is'
	ELSE INTERPRET nameString||'='||"NULL"
    END
DO i = 1 to numReturnedVars
	say returnedVar.i||" contains    : "||VALUE(returnedVar.i)
END


/* Now the variables can be used in rexx statements e.g. 		*/
/* if fs \= "NULL"											 	*/
/* then ADDRESS SYSTEM 'ls -l '||fs						 		*/


EXIT(0);

/* fileExists procedure test to see if passed argument is a file */
fileExists:
    procedure;
    parse arg fileName
    cmd = 'test -s '||"'"fileName"'"
    trace off
    ADDRESS SYSTEM cmd
    trace error
    return(RC);


START_PASHUA_INPUT:
/* # Set window title */
/* *.title = Introducing Pashua */
/*  */
/* # Introductory text */
/* tb.type = text */
/* tb.default = Pashua is an application for generating dialog windows from programming languages which lack support for creating native GUIs on Mac OS X. Any information you enter in this example window will be returned to the calling script when you hit “OK”; if you decide to click “Cancel” or press “Esc” instead, no values will be returned.[return][return]This window shows nine of the UI element types that are available. You can find a full list of all GUI elements and their corresponding attributes in the documentation (➔ Help menu) that is included with Pashua. */
/* tb.height = 276 */
/* tb.width = 310 */
/* tb.x = 340 */
/* tb.y = 44 */
/* tb.tooltip = This is an element of type “text” */
/*  */
/* # Display Pashua's icon */
/* img.type = image */
/* img.x = 435 */
/* img.y = 248 */
/* img.maxwidth = 128 */
/* img.tooltip = This is an element of type “image” */
/*  */
/* # Add a text field */
/* tx.type = textfield */
/* tx.label = Example textfield */
/* tx.default = Textfield content */
/* tx.width = 310 */
/*  */
/* # Add a filesystem browser */
/* ob.type = openbrowser */
/* ob.label = Example filesystem browser (textfield + open panel) */
/* ob.width=310 */
/* ob.tooltip = Blabla filesystem browser */
/*  */
/* # Define radiobuttons */
/* rb.type = radiobutton */
/* rb.label = Example radiobuttons */
/* rb.option = Radiobutton item #1 */
/* rb.option = Radiobutton item #2 */
/* rb.option = Radiobutton item #3 */
/* rb.option = Radiobutton item #4 */
/* rb.default = Radiobutton item #2 */
/*  */
/* # Add a popup menu */
/* pop.type = popup */
/* pop.label = Example popup menu */
/* pop.width = 310 */
/* pop.option = Popup menu item #1 */
/* pop.option = Popup menu item #2 */
/* pop.option = Popup menu item #3 */
/* pop.default = Popup menu item #2 */
/*  */
/* # Add a checkbox */
/* chk1.type = checkbox */
/* chk1.label = Pashua offers checkboxes, too */
/* chk1.rely = -18 */
/* chk1.default = 1 */
/*  */
/* # Add another one */
/* chk2.type = checkbox */
/* chk2.label = But this one is disabled */
/* chk2.disabled = 1 */
/*  */
/*  */
/* # Add a cancel button with default label */
/* cb.type=cancelbutton */
/*  */
END_PASHUA_INPUT:
