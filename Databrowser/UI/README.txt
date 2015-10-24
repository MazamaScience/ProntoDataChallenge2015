UI README

========
>>> html
========

  ==========
  index.html
  ==========
  main html file. Contains links to JS and CSS scripts. Read about required JS files in the JS section.

  =========
  >>> views
  =========
  contains html templates which are injected into the ui-view tags in main.hmtl.

    =========
    main.html
    =========
    contains html template for the "main" view. This is where all of the Databrowser UI and logic lives.

    ==========
    about.html
    ==========
    contains html template for the "about" view. This often goes unused but is useful for writing down documentation or explanations of how to use the UI. 





=======
>>> CSS 
=======

  ==========
  >>> images
  ==========
  Images (not including output images from the server) go here. CSS Sprites would be a common use case.

  ===========================
  Mazama_databrowser_base.css
  ===========================
  The default CSS for the generic databrowser. This file should remain unedited. Any changes to default CSS rules should be written as overrides in Mazama_databrowser.css.

  ======================
  Mazama_databrowser.css
  ======================
  This is where all new CSS should be written. Import tags at the start of the file load Bootstrap and the default css. When the makefile's "build" command is run, all of these files are concatonated into one "build.css" file, with the CSS rules from Mazama_darabrowser.css at the end.






======
>>> JS
======