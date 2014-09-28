# YAML comes built-in with ruby
require 'yaml'

# 'commands' will be an array of commands we upload to MAPI, after converting it to YAML
commands = []

# Must always include TA or instructor credentials in 'commands'
credentials = {
        "email"    => "MY_TA_EMAIL@example.com",
        "password" => "MY_PASSWORD"
        }

# Add credentials to 'commands'
commands << { "credentials" => credentials }

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
        "name"            => "Homework 5",
        # note that min_points and max_points are only necessary on leaves
        "assignment_file" => "https://some_site.com/my_file1.pdf",
        "solution_file"   => "https://some_site.com/my_file2.pdf"
        }
new_assignment["subparts"] = [] # append dictionaries for each subpart into this array
new_assignment["subparts"] << { # Add Part 1
                      "name"       => "Part 1",
                      "index"       => [1],
                      "min_points" => 0,  # required for leaves
                      "max_points" => 15, # required for leaves
                      "pages"      => [1] # required for leaves
                      }
new_assignment["subparts"] << { # Add Part 2
                      "name"  => "Part 2", 
                      "index" => [2] # not a leaf, so don't include other fields
                      }
new_assignment["subparts"] << { # Add Part 2.1
                      "name"       => "Part 2.1",
                      "index"      => [2, 1],
                      "min_points" => 0,  # required for leaves
                      "max_points" => 7,  # required for leaves
                      "pages"      => [2] # required for leaves
                      }
new_assignment["subparts"] << { # Add Part 2.2
                      "name"       => "Part 2.2",
                      "index"      => [2, 2],
                      "min_points" => 0,  # required for leaves
                      "max_points" => 4,  # required for leaves
                      "pages"      => [3] # required for leaves
                      }
new_assignment["subparts"] << { # Add Part 3
                      "name"  => "Part 3", 
                      "index" => [3] # not a leaf, so don't include other fields
                      }
new_assignment["subparts"] << { # Add Part 3.1
                      "name"  => "Part 3.1", 
                      "index" => [3, 1] # not a leaf, so don't include other fields
                      }
new_assignment["subparts"] << { # Add Part 3.1.1
                      "name"       => "Part 3.1.1",
                      "index"      => [3, 1, 1],
                      "min_points" => 0,  # required for leaves
                      "max_points" => 5,  # required for leaves
                      "pages"      => [3] # required for leaves
                      }
new_assignment["subparts"] << { # Add Part 3.2
                      "name"       => "Part 3.2",
                      "index"      => [3, 2],
                      "min_points" => 0,  # required for leaves
                      "max_points" => 13,  # required for leaves
                      "pages"      => [4, 5, 6] # required for leaves
                      }
                      
commands << { "new_assignment" => new_assignment }

# dump 'commands' dictionary into yaml file that can be uploaded
File.open('FILE_TO_UPLOAD.yaml', 'w') { |f| f.write commands.to_yaml }
