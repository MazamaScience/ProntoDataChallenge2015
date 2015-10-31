#!__PYTHON__
# -*- coding: utf-8 -*-
#
# Name:
#       __DATABROWSER__.cgi
#
# Author:
#       Jonathan Callahan <jonathan@mazamascience.com>
#
# SECURITY: 1) All incoming parameter names and values are validated before being used.
# SECURITY: 2) All commands are run inside a try/except block.

__version__ = "1.1.0"  # locally installed packages


################################################################################
# BEGIN configuration.
################################################################################

# Variables configured with config/Makefile_vars_~
URL_PATH = '__URL_PATH__'
DATABROWSER_PATH = '__DATABROWSER_PATH__'
OUTPUT_DIR = '__OUTPUT_DIR__'
CACHE_SIZE = __CACHE_SIZE__

# Directories
URL_OUT = URL_PATH + '/' + OUTPUT_DIR
ABS_OUT = DATABROWSER_PATH + '/' + OUTPUT_DIR

# Minimal request object
request = {'debug': 'none',
           'responseType': 'json',
           'plotWidth': '1024',
           'productType': 'systemTable',
           'plotType': 'barplot_weekByDay'}

# NOTE:  You can set up a request object with all required parameters and run this
# NOTE:  this cgi script from the command line for debugging.
#request = {'debug': 'transcript',
#           'responseType': 'json',
#           'plotWidth': '1024',
#           'plotHeight': '1024',
#           'plotDevice': 'png',
#           'language': 'en',
#           'lineColor': 'black',
#           'plotType': 'TrigFunctions',
#           'trigFunction': 'cos'}



# Create a dictionary of valids against which incoming parameters will be compared
valids = {}

# Start off by assuming all parameters are alpha-numeric strings
for key in request.keys():
    valids[key] = ['ALPHANUMERIC']

# Now override for specific elements that are numeric
numeric_parameters = ['plotWidth','plotHeight']
for key in numeric_parameters:
    valids[key] = ['NUMERIC']

# Special case for 'debug'
valids['debug'] = ['none', 'transcript']

# NOTE:  This should be enough protection but specific values can be included in
# NOTE:  order to trap bad parameters and generate error strings within this CGI
# NOTE:  script.
# NOTE:  E.g. valids['fruit'] = ['apple','banana','orange']

# NOTE:  Special case for 'responseType'.
# NOTE:  You should enable only those types that are supported by the R code.
# NOTE:  For responses handled by the user interface this should be 'json'.
# NOTE:  Other common types allow the databrowser to serve as web service.
# NOTE:  These would include:   'csv', 'kml' and 'png'
valids['responseType'] = ['json','csv']


################################################################################
# END configuration. BEGIN setup.
################################################################################


# Initialize the default status and message strings
status = 'OK'
error_text = ''
debug_text = ''

# Import required python modules
import sys, os, re, time
import cgi
# The json module was introduced in python 2.6
# For backwards compatibility you can import simplejson
try:
    import json
except ImportError:
    import simplejson as json 

start = time.time()
timepoint = time.time()

# Set up the TRANSCRIPT file and redirect stdout there
try:
    transcript = DATABROWSER_PATH + '/TRANSCRIPT.txt'
    sys.stdout=open(transcript,'w')
    transcript_was_used = True
except Exception, e:
    transcript_was_used = False
    status = 'ERROR'
    error_text = "CGI ERROR: cannot open transcript file:  " + str(e)

# Profiling point
elapsed = time.time() - timepoint
debug_text += "\n# %07.4f seconds to open TRANSCRIPT.txt\n" % elapsed
timepoint = time.time()

# Debugging info
debug_text += "\nEnvironment Variables:\n"
for param in os.environ.keys():
  debug_text += "\t%20s: %s\n" % (param, os.environ[param])


# Use the parameter:value pairs from the web server to override the default 'request' parameters
FS = cgi.FieldStorage()
for key in FS.keys():
    try:
        request[key] = ",".join(FS.getlist(key))
    except Exception, e:
        status = 'ERROR'
        error_text = "CGI ERROR: incoming parameter '%s' has no value:  %s" % (key,str(e))

    # parameters not mentioned in request{} above are assigned to ALPHANUMERIC by default
    if key not in valids:
        valids[key] = ['ALPHANUMERIC']

# Validate every parameter against the list of valids for that parameter
debug_text += "\nRequest:\n"
for key in request:
    value = request[key]
    debug_text += "\t%s = '%s'\n" % (key,value)
    
    if key == 'plotWidth':
        try:
            if int(value) < 100 or int(value) > 2000:
                request['plotWidth'] = '1024'
        except Exception, e:
            status = 'ERROR'
            error_text = "CGI ERROR: parameter '%s' has a value of '%s' which is not an integer: %s" % (key,value,e)

    elif key == 'plotHeight':
        try:
            if int(value) < 100 or int(value) > 1200:
                request['plotHeight'] = request['plotWidth']
        except Exception, e:
            status = 'ERROR'
            error_text = "CGI ERROR: parameter '%s' has a value of '%s' which is not an integer: %s" % (key,value,e)

    elif key == 'MazamaSubset':
        status = 'OK'
        # Do not check

    elif valids[key][0] == 'NUMERIC':
        try:
            val = float(value)
        except Exception, e:
            status = 'ERROR'
            error_text = "CGI ERROR: parameter '%s' has a value of '%s' which is not numeric: %s" % (key,value,e)

    elif valids[key][0] == 'ALPHANUMERIC':
        # NOTE:  Accept '' as a valid alphanumeric value
        if value != '':
            # NOTE:  Accept alphanumeric strings which may also contain '.', ',', '_' or '-' or ' '
            if not value.replace('.','').replace(',','').replace('_','').replace('-','').replace('(','').replace(')','').replace(' ','').isalnum():    
                status = 'ERROR'
                error_text = "CGI ERROR: parameter '%s' has a value of '%s' which is not alphanumeric" % (key,value)

    else:
        if value not in valids[key]:
            status = 'ERROR'
            error_text = "CGI ERROR: parameter '%s' has a value of '%s' which is not a valid value" % (key,value)


# Profiling point
elapsed = time.time() - timepoint
debug_text += "\n# %07.4f seconds to validate parameters\n" % elapsed
timepoint = time.time()


################################################################################
# END setup. BEGIN generation of result.
################################################################################

from_cache = False

if status == 'OK':

    # Create unique filebase from request    
    import copy
    import hashlib

    # Remove 'responseType' and any other parameters that do not require the
    # generation of new output products.  We want things to be found in cache
    # as often as possible.
    dummyDict = copy.deepcopy(request)
    dummy = dummyDict.pop('responseType')
    unique_ID = hashlib.sha256(str(dummyDict)).hexdigest()

    # Set up filenames to be used
    abs_base = ABS_OUT + '/' + unique_ID
    rel_base = OUTPUT_DIR + '/' + unique_ID
    abs_png = abs_base + '.png'
    abs_json = abs_base + '.json'
    abs_file = abs_base + '.' + request['responseType']

    # modify the request
    request['outputFileBase'] = unique_ID

    # Determine whether the output file is found in cache
    if (request['responseType'] == 'json'):
        from_cache = os.path.exists(abs_png) and os.path.exists(abs_json)
    else:
        from_cache = os.path.exists(abs_file)

    # Check for a previously generated result.
    if from_cache:
        # File exists -- no action necessary
        debug_text += "\n'%s' already exists\n" % abs_file
        debug_text += "\nRetrieving file from cache\n"
        elapsed = time.time() - start
        debug_text += "\n# %07.4f seconds from start to finish\n" % elapsed
        print(debug_text)
        from_cache = True

    else:

        # We're going to generate a new plot so we need to make sure
        # that we have room in the cache.

        # Cache management ---------------------------------------------------------
    
        try:
            # Compile statistics on all files in the output directory and subdirectories
            stats = []
            totalSize = 0
            for root, dirs, files in os.walk(ABS_OUT):
                for file in files:
                  path = os.path.join(root,file)
                  statList = os.stat(path)
                  # path, size, atime
                  newStatList = [path, statList.st_size, statList.st_atime]
                  totalSize = totalSize + statList.st_size
                  # don't want hidden files like .htaccess so don't add stuff that starts with .
                  if not file.startswith('.'):
                      stats.append(newStatList)
            
            # Sort file stats by last access time
            stats = sorted(stats, key=lambda file: file[2])
            
            # Delete old files until we get under CACHE_SIZE (configured in megabytes)
            numDeletions = 0
            while totalSize > CACHE_SIZE * 1000000:
                # front of stats list is the file with the smallest (=oldest) access time
                lastAccessedFile = stats[0]
                # index 1 is where size is
                totalSize = totalSize - lastAccessedFile[1]
                # index 0 is where path is
                os.remove(lastAccessedFile[0])
                # remove the file from the stats list
                stats.pop(0)
                numDeletions = numDeletions + 1
                
        except Exception, e:
            status = 'ERROR'
            error_text = 'CGI ERROR: ' + str(e)

        # Profiling point
        elapsed = time.time() - timepoint
        debug_text += "\n# %07.4f seconds to keep the cache at %07.2f megabytes -- %d files deleted\n" % (elapsed,CACHE_SIZE,numDeletions)
        timepoint = time.time()
    
        # END Cache management -----------------------------------------------------
    
        # Need to generate a new plot
        try:
            import rpy2.robjects as robjects
            r = robjects.r
        except Exception, e:
            status = 'ERROR'
            error_text = 'CGI ERROR: ' + str(e)

        elapsed = time.time() - timepoint
        debug_text += "\n# %07.4f seconds to import the rpy module\n" % elapsed
        timepoint = time.time()

        script = DATABROWSER_PATH + '/__DATABROWSER__.R' 

        # Create debugging output to appear in the transcript
        r_commands = "\n# NOTE:  Next lines are for interactive debugging in R.\n\n"
        
        r_commands += "# Switch to databrowser WD to load packages and lists\n"
        r_commands += "savedwd <- getwd()\n"
        r_commands += "setwd('" + DATABROWSER_PATH + "')\n"
        r_commands += "source('" + script + "')\n\n"

        r_commands += "# Switch back to original WD and add JSON to datalist\n"
        r_commands += "setwd(savedwd)\n"
        r_commands += "jsonArgs='" + json.dumps(request) + "'\n"
        r_commands += "infoList <- createInfoList(jsonArgs)\n"
        r_commands += "infoList$scriptDir <- './R/'\n"
        r_commands += "infoList$dataDir <- './Databrowser/data_local/'\n"
        r_commands += "textListScript <- './R/createTextList_en'\n" 
        r_commands += "infoList$outputDir <- '.'\n"


        # Run the R commands using the rpy2 module 
        try:

            # We convert the incoming request dictionary into a JSON string and
            # pass this string to the databrowser function where it is converted
            # into the infoList.
            r_command = "__DATABROWSER__(jsonArgs='" + json.dumps(request) + "')"
            
            # The R script will always return a JSON string
            # rpy2 will interpret this as a string vector so we need to pull out the first element
            dir = robjects.r.dir(DATABROWSER_PATH) # Not used, would like to pass to script as arg
            r.source(script, chdir=True)  # chdir=TRUE allows use to access package dir without RJSON
            return_json = r(r_command)[0]
            debug_text += "\n# return_json = ::%s::\n" % return_json

            # Profiling point
            elapsed = time.time() - timepoint
            debug_text += "\n# %07.4f seconds to run the R commands\n" % elapsed
            debug_text += r_commands
            timepoint = time.time()

            elapsed = time.time() - start
            debug_text += "\n# %07.4f seconds from start to finish\n" % elapsed

            print(debug_text)

        except Exception, e:
            status = 'ERROR'
            error_text = 'R ERROR: ' + str(e)
            try:
                debug_file = DATABROWSER_PATH + "/DEBUG.txt"
                dbg = open(debug_file,'a')
                dbg.write("\n\nR ERROR on " + str(time.ctime()) + ":\n")
                dbg.write(error_text)
                dbg.write("R COMMANDS:\n" + r_commands + "\n")
                dbg.close()
            except Exception, e:
                error_text = 'CGI ERROR: ' + str(e)
                print("\nAn error occurred writing the debug file: " + error_text)


################################################################################
# END generation of result. BEGIN response.
################################################################################


# Restore stdout
if transcript_was_used:
    sys.stdout.close()
    sys.stdout=sys.__stdout__

########################################
# JSON response
########################################
if request['responseType'] == 'json':
    
    # Set up the response object
    response = {}
    if status == 'OK':
        if from_cache:
            # Read the json response object if it had been stored previously so that return_json can be retrieved
            try:
                f = open(abs_json,'r')
                response = json.loads(f.read())
                f.close()
            except Exception, e:
                status = 'ERROR'
                error_text = 'CGI ERROR: cannot read cached json file: ' + str(e)
                response = {'status':status, 'error_text':error_text}
        else:
            # Otherwise, create and store the json response object
            response = {'status':status,
                        'rel_base':rel_base,
                        'return_json':return_json}
            try:
                f = open(abs_json,'w')
                f.write(json.dumps(response))
                f.close()
            except Exception, e:
                status = 'ERROR'
                error_text = 'CGI ERROR: cannot write json file to cache: ' + str(e)
                response = {'status':status, 'error_text':error_text}
    
    elif status == 'ERROR':
        response = {'status':status, 'error_text':error_text }
    
    else:
        response = {'status':status, 'error_text':'CGI ERROR: An unknown error occurred.' }
    
    # Write out the JSON response for AJAX
    if request['debug'] == 'none':
        sys.stdout.write("Content-type: application/json\n\n")
        sys.stdout.write(json.dumps(response))
    
    # Write out the JSON response for humans
    elif request['debug'] == 'transcript':
        sys.stdout.write("Content-type: text/plain\n\n")
        sys.stdout.write("TRANSCRIPT:\n")
        sys.stdout.write(debug_text + "\n")
        sys.stdout.write(json.dumps(response, sort_keys=True, indent=4)) # pretty
        sys.stdout.write("\n")
        sys.stdout.write("\nEND OF TRANSCRIPT\n")
    
########################################
# various ASCII responses
########################################
elif (request['responseType'] == 'csv') or \
     (request['responseType'] == 'kml'):

    if status == 'OK':
        # Read the appropriate file and return it
        try:
            f = open(abs_file,'r')
            response = f.read()
            f.close()
        except Exception, e:
            response = 'CGI ERROR: cannot read ' + request['responseType'] + ' file: ' + str(e)
        
    elif status == 'ERROR':
        response = 'ERROR: ' + error_text
    
    else:
        response = 'CGI ERROR: An unknown error occurred.'
    
    # Write out the response with the appropriate mime type
    if request['responseType'] == 'csv':
        sys.stdout.write("Content-Type: text/csv\n")
    elif request['responseType'] == 'kml':
        sys.stdout.write("Content-Type: application/vnd.google-earth.kml+xml\n")
    else:
        sys.stdout.write("Content-Type: text/plain\n")

    # Use Content-Disposition to assign a filename
    # For example:  filename = "HysplitTrajectories_" + request['metStart'] + "." + request['responseType']
    filename = "CHANGEME_" + request['plotType'] + "." + request['responseType']
    line = "Content-Disposition: attachment; filename=" + filename + ";\n\n"
    sys.stdout.write(line)
    sys.stdout.write(response)
    
########################################
# Unknown response
########################################

else:
    sys.stdout.write("Content-type: text/plain\n\n")
    all_valids = '[' + ",".join(valids['responseType']) + ']'
    response = 'ERROR: responseType="' + request['responseType'] + '" is not not one of ' + all_valids
    sys.stdout.write(response)
    sys.stdout.write("\n")
           
    
################################################################################
# END response. All done!
################################################################################


# If this is being run from the command line, add another blank line
if FS.keys() == []:
    print("\n")

