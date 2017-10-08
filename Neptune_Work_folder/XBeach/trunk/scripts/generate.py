#!/usr/bin/env python

"""
Generate fortran sources
"""

import os
import glob
import inspect
import re
import json
import logging

try:
    import mako
except ImportError:
    msg = """
Part of the sourcecode of XBeach is autogenerated.
This generation process uses the python package mako.
The mako python package was not found.
You can install mako package by the following command in a terminal/dos box:

pip install mako
"""
    print(msg)
    raise
import mako.template
import mako.lookup

logger = logging.getLogger(__name__)
logging.basicConfig()
logger.setLevel(logging.DEBUG)
def main():
    try:
        curfile = os.path.abspath(__file__)
    except NameError:
        curfile = os.path.abspath(inspect.getsourcefile(lambda : None))
    srcdir = os.path.join(os.path.dirname(curfile), '..', 'src', 'xbeachlibrary')
    templatedir = os.path.join(srcdir, "templates")
    variables_file = os.path.join(srcdir, 'variables.f90')
    parameter_file = os.path.join(srcdir, 'params.F90')

    variable_re = re.compile(r'''
    ^\s*                                                                 # start of the line
    (?P<fortrantype>(character|logical|double\s+precision|integer|real)) # type
    .*                                                                   # anything
    (target)                                                             # the word target
    .*                                                                   # anything
    (::)                                                                 # double colon
    \s*                                                                  # possible spaces
    (?P<name>\w[\w\d]*)                                              # the variable name
    (?P<dimension>([(][:,\w]+[)])?)                                      # dimension
    .*                                                                   # anything
    [!][<]?\s*                                                           # comment
    ([(](?P<altname>[\w/\d-]+)[)])?                                      # alternative name
    \s*                                                                  # space
    [[](?P<unit>[\w/\d\-\._]+)[]]                                            # unit
    \s*                                                                  # space
    (?P<description>.*?)                                                 # description
    \s*                                                                  # space
    ((?P<json>[{].*[}]))?                                                # JSON key-value pairs
    \s*                                                                  # space
    $                                                                    # end of line
    ''',
    re.VERBOSE)

    parameter_re = re.compile(r'''
    ^\s*                                                                 # start of the line
    (?P<fortrantype>(character|logical|double\s+precision|integer|real)) # type
    .*                                                                   # anything
    (::)                                                                 # double colon
    \s*                                                                  # possible spaces
    (?P<name>\w[\w\d]*)                                                  # the variable name
    (?P<dimension>([(][:,\d\w]+[)])?)                                    # dimension
    .*                                                                   # anything
    [!][<]?\s*                                                           # comment
    [[](?P<unit>[\w/\d\-\._]+)[]]                                          # unit
    \s*                                                                  # space
    (?P<description>.*?)                                                 # description
    \s*                                                                  # space
    ((?P<json>[{].*[}]))?                                                # JSON key-value pairs
    \s*                                                                  # space
    $                                                                    # end of line
    ''',
    re.VERBOSE)

    FORTRANTYPESMAP = {
        'logical': 'bool',
        'character': 'char',
        'double precision': 'double',
        'real': 'float',
        'integer': 'int'
    }


    variables = []
    with open(variables_file) as f:
        for line in f.readlines():
            match = variable_re.match(line)
            if match:
                variable = match.groupdict()
                if variable['dimension'].strip():
                    variable['rank'] = variable['dimension'].count(',') + 1
                else:
                    variable['rank'] = 0
                variable['type'] = FORTRANTYPESMAP[variable['fortrantype']]
                if "json" in variable and variable["json"]:
                    try:
                        variable.update(json.loads(variable["json"]))
                    except ValueError:
                        logging.exception("Can' load json:\n{}\n".format(variable["json"]))
                variables.append(variable)


    parameters = []
    with open(parameter_file) as f:
        for line in f.readlines():
            match = parameter_re.match(line)
            if match:
                parameter = match.groupdict()
                if parameter['dimension'].strip():
                    parameter['rank'] = parameter['dimension'].count(',') + 1
                else:
                    parameter['rank'] = 0
                parameter['type'] = FORTRANTYPESMAP[parameter['fortrantype']]
                if "json" in parameter and parameter["json"]:
                    try:
                        parameter.update(json.loads(parameter["json"]))
                    except ValueError:
                        logging.exception("Can' load json:\n{}\n".format(parameter["json"]))
                parameters.append(parameter)


    ISOTYPESMAP = {
        'bool': "logical(c_bool)",
        'char': "character(kind=c_char)",
        'double': "real(c_double)",
        'float': "real(c_float)",
        'int': "integer(c_int)"
    }


    def dimstr(shape):
        shapetxt = ",".join(str(x) for x in shape)
        if shapetxt:
            return "(" + shapetxt + ")"
        else:
            return ""
    # not documented function in glob
    templates = glob.glob1(templatedir, '*.f90')

    lookup = mako.lookup.TemplateLookup(directories=[templatedir], module_directory='/tmp/mako_modules')

    logger.info("parsing templates in %s", templatedir)
    for template_name in templates:
        template = lookup.get_template(template_name)
        filename = template_name.replace('.f90', '.inc')
        logger.info("converting %s to %s", template_name, filename)
        with open(os.path.join(srcdir, filename), 'w') as f:
            rendered = template.render(**locals())
            #print(rendered)
            f.write(rendered)

    # TODO, rewrite templates so we can just use variables....

    jsondata = {
        "comment": "do not edit this file, it is autogenerated by generate.py",
        "variables": variables
    }
    # store the extracted variables
    json.dump(jsondata, open(os.path.join(srcdir, 'extractedvariables.json'), 'w'), indent=4)
if __name__ == "__main__":
    main()
