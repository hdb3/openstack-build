#!/usr/bin/python

import netifaces
from sys import exit, stderr
import colorama

def getaddrs():
    addrs = []
    for iface in netifaces.interfaces():
        ifaddresses = netifaces.ifaddresses(iface)
        if netifaces.AF_INET in ifaddresses:
            addrs.append((iface,ifaddresses[netifaces.AF_INET][0]['addr']))
    return addrs

def getroles():
    roles = {}
    try:
        infile = open("roles","r")
    except:
        print >> stderr, cfr + "Hmmm, I had a teensy problem trying to find your role configuration file: is there a file somewhere here called 'roles'?"
        exit(1)
    for line in infile.readlines():
        if line[0] != '#':
            words = line.split()
            if len(words) > 1:
                roles[words[0]] = words[1]
    return roles

# first process the roles without considering local roles issues

def main():
    envstrings = []
    roleaddrs = getroles()
    roles = {}
    for addr,role in roleaddrs.iteritems():
        if role not in roles:
            roles[role] = []
        roles[role].append(addr)

    print >> stderr, cfg + "the following roles were found:"
    for role, addrs in roles.iteritems():
        print >> stderr, cfg, "role %s: " % role,
        print >> stderr, cfg , addrs

    if 'controller' not in roles:
        print >> stderr, cfr + "Warning! - no controller was found - cannot set controller IP"
    else:
        controller_ip = roles['controller'][0]
        envstrings.append(("CONTROLLER_IP",controller_ip))
        if len(roles['controller']) > 1:
            print >> stderr, cfy + "Warning! - more than one controller was found - using first candidate for controller IP (%s)" % controller_ip


    # now grab a list of lcal interface addresses and see if we match any of them to our role list from the configuratioon file

    addrs = getaddrs()
    my_roles = []
    for (iface,addr) in addrs:
        if addr in roleaddrs:
            my_roles.append((roleaddrs[addr],addr,iface))
            # print >> stderr, "role found: %s (address %s on interface %s)" % (roleaddrs[addr],addr,iface)
    if len(my_roles) == 0:
        print >> stderr, cfr + "Warning - no role was found based on local addresses for this host"
    else:
        envstrings.append(("MY_IP",my_roles[0][1]))
        envstrings.append(("MY_ROLE",my_roles[0][0]))
        if len(my_roles) == 1:
            print >> stderr, cfg + "Happy days! - a role was found based on local addresses for this host - role found: %s (address %s on interface %s)" % my_roles[0]
        else:
            print >> stderr, cfy + "Warning - multiple roles found based on local addresses for this host",
            print >> stderr, my_roles
    return envstrings
# end of main!


cfr = colorama.Fore.RED
cfg = colorama.Fore.GREEN
cfy = colorama.Fore.YELLOW
colorama.init()

try:
    envstrings = main()
except:
    print >> stderr,colorama.Fore.RESET
    colorama.deinit()
else:
    print >> stderr,colorama.Fore.RESET
    # print colorama.Fore.RESET
    colorama.deinit()
    for envval in envstrings:
        print "export %s=%s"  % (envval)
