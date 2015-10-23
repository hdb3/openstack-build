#!/usr/bin/python

import netifaces

def getaddrs():
    addrs = []
    for iface in netifaces.interfaces():
        ifaddresses = netifaces.ifaddresses(iface)
        if netifaces.AF_INET in ifaddresses:
            addrs.append((iface,ifaddresses[netifaces.AF_INET][0]['addr']))
    return addrs

def getroles():
    roles = {}
    infile = open("roles","r")
    for line in infile.readlines():
        words = line.split()
        if len(words) > 1:
            roles[words[0]] = words[1]
    return roles

# first process the roles without considering local roles issues

roleaddrs = getroles()
roles = {}
for addr,role in roleaddrs.iteritems():
    if role not in roles:
        roles[role] = []
    roles[role].append(addr)

print "the following roles were found:"
for role, addrs in roles.iteritems():
    print "role %s: " % role,
    print addrs

if 'controller' not in roles:
    print "Warning! - no controller was found - cannot set controller IP"
else:
    controller_ip = roles['controller'][0]
    if len(roles['controller']) > 1:
        print "Warning! - more than one controller was found - using first candidate for controller IP (%s)" % controller_ip


# now grab a list of lcal interface addresses and see if we match any of them to our role list from the configuratioon file

addrs = getaddrs()
my_roles = []
for (iface,addr) in addrs:
    if addr in roleaddrs:
        my_roles.append((roleaddrs[addr],addr,iface))
        # print "role found: %s (address %s on interface %s)" % (roleaddrs[addr],addr,iface)
if len(my_roles) == 0:
    print "Warning - no role was found based on local addresses for this host"
else:
    if len(my_roles) == 1:
        print "Happy days! - a role was found based on local addresses for this host - role found: %s (address %s on interface %s)" % my_roles[0]
    else:
        print "Warning - multiple roles found based on local addresses for this host",
        print my_roles
