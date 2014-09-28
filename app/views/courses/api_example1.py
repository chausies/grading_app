###########################################################################
# Sample python program to create and upload YAML file to MAPI that makes #
# an assignment with subparts.                                            #
###########################################################################

# To get YAML for python, run 'pip install pyyaml'
import yaml

# assuming the url for this page is magicgrader.heroku.com/courses/##/api_submit
my_course_number     = "##" 
yaml_file_name       = "FILE_TO_UPLOAD.yaml"
assignment_file_name = "relative/path/to/example_hw5.pdf"
solution_file_name   = "relative/path/to/example_hw5sol.pdf"

##################################
# Creating YAML file of commands #
##################################
print "Creating YAML file to upload to MAPI..."

# 'commands' will be an array of commands we upload to MAPI, after converting it to YAML
commands = []

# Must always include TA or instructor credentials in 'commands'
credentials = {
        "email":    "MY_TA_EMAIL@example.com",
        "password": "MY_PASSWORD"
        }

# Add credentials to 'commands'
commands.append({ "credentials": credentials })

# How to create a new assignment with subparts
# Homework 5
# |-- Part 1
# |-- Part 2
#      |-- Part 2.1
#      |-- Part 2.2
#  |-- Part 3
#      |-- Part 3.1
#          |-- Part 3.1.1
#      |-- Part 3.2
new_assignment = {
        "name"            : "Homework 5",
        # note that min_points and max_points are only necessary on leaves
        }
new_assignment["subparts"] = [] # append dictionaries for each subpart into this array
new_assignment["subparts"].append( { # Add Part 1
                      "name":       "Part 1",
                      "index":      [1],
                      "min_points": 0,  # required for leaves
                      "max_points": 15, # required for leaves
                      "pages":      [1] # required for leaves
                      }
                    )
new_assignment["subparts"].append( { # Add Part 2
                      "name":  "Part 2",
                      "index": [2] # not a leaf, so don't include other fields
                      }
                    )
new_assignment["subparts"].append( { # Add Part 2.1
                      "name":       "Part 2.1",
                      "index":      [2, 1],
                      "min_points": 0,  # required for leaves
                      "max_points": 7,  # required for leaves
                      "pages":      [2] # required for leaves
                      }
                    )
new_assignment["subparts"].append( { # Add Part 2.2
                      "name":       "Part 2.2",
                      "index":      [2, 2],
                      "min_points": 0,  # required for leaves
                      "max_points": 4,  # required for leaves
                      "pages":      [3] # required for leaves
                      }
                    )
new_assignment["subparts"].append( { # Add Part 3
                      "name":  "Part 3",
                      "index": [3] # not a leaf, so don't include other fields
                      }
                    )
new_assignment["subparts"].append( { # Add Part 3.1
                      "name":  "Part 3.1",
                      "index": [3, 1] # not a leaf, so don't include other fields
                      }
                    )
new_assignment["subparts"].append( { # Add Part 3.1.1
                      "name":       "Part 3.1.1",
                      "index":      [3, 1, 1],
                      "min_points": 0,  # required for leaves
                      "max_points": 5,  # required for leaves
                      "pages":      [3] # required for leaves
                      }
                    )
new_assignment["subparts"].append( { # Add Part 3.2
                      "name":       "Part 3.2",
                      "index":      [3, 2],
                      "min_points": 0,        # required for leaves
                      "max_points": 13,       # required for leaves
                      "pages":      [4, 5, 6] # required for leaves
                      }
                    )
                      
commands.append({ "new_assignment": new_assignment })

# dump 'commands' dictionary into yaml file that can be uploaded
with open(yaml_file_name, 'w') as outfile:
  outfile.write( yaml.dump(commands) )


######################################################################
# upload the YAML file, along with the assignment and solution files #
######################################################################
print "Uploading files to MAPI..."

import requests

MAPI_url = "http://magicgrader.heroku.com/courses/" + my_course_number + "/api_submit"
yaml_file       = open(yaml_file_name, 'rb')
assignment_file = open(assignment_file_name, 'rb')
solution_file   = open(solution_file_name, 'rb')
# get response of sending the YAML file and other files
try:
  response = requests.post( MAPI_url, 
    files={
      'file': yaml_file,
      'assignment_file': assignment_file,
      'solution_file': solution_file
      } 
    )
except requests.ConnectionError as e:
  print "***Can't connect to MagicGrader. Check internet connection.***"
  raise e


#########################################################################
# print out all alert tags, which have the results of all your commands #
# good for verifying what things worked, or finding what errored        #
#########################################################################
print "MAPI's responses: "

from HTMLParser import HTMLParser
import re

h = HTMLParser()
output = h.unescape(response.content)

for line in output.splitlines():
  if ('alert-' in line) and not ("*alert-" in line):
    content_search = re.search('<.*alert-([^"]*)">(.*)<.*>', line)
    alert_type = content_search.group(1).upper()
    alert_content = content_search.group(2)
    print "\t" + alert_type + ": " + alert_content
