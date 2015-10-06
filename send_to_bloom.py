#!/usr/bin/env python

# pip install pygithub3

import re
import yaml
import time
import sys
from urllib import urlopen
from pygithub3 import Github

import ssl
from functools import wraps
def sslwrap(func):
    @wraps(func)
    def bar(*args, **kw):
        kw['ssl_version'] = ssl.PROTOCOL_TLSv1
        return func(*args, **kw)
    return bar

ssl.wrap_socket = sslwrap(ssl.wrap_socket)

def get_release_version(distro, repo):
    release_version = None
    try:
        u = urlopen("http://raw.github.com/ros/rosdistro/master/%s/distribution.yaml"%(distro))
        d = yaml.safe_load(u)

        release_version = re.sub("-[0-9]*$","",d['repositories'][repo]['release']['version'])
    except:
        pass

    print "release %s/%s -> %s"%(distro, repo, release_version)
    sys.stdout.flush()
    return release_version

def get_repository_version(org, repo):
    repository_version = None
    try:
        gh = Github(user=org, repo=repo)
        tags = gh.repos.list_tags()
        sorted_tags = sorted(filter(lambda x: re.match("^[0-9.]*$", x.name), tags.all())) # sort only numerical version tags
        repository_version = sorted_tags[0].name

    except:
        pass

    print "repository %s/%s -> %s"%(org, repo, repository_version)
    sys.stdout.flush()
    return repository_version



# usage send_to_bloom jsk-ros-pkg jsk_common
import sys
if len(sys.argv) > 4 :
    print "usage: %s jsk-ros-pkg jsk_common"%sys.argv[0]
    exit(-1)

organization = sys.argv[1]
repository = sys.argv[2]
if len(sys.argv) == 4:
    repository_name = sys.argv[3]
else:
    repository_name = repository

# if it already pull request for ros/rosdistro
gh = Github(user='ros', repo='rosdistro')
if filter(lambda x: repository_name in x.title, gh.pull_requests.list().all()) != []:
    print "pull requests exists in ros/rosdistro"
    exit(0)

import bloom
from bloom.util import disable_git_clone
from bloom.util import quiet_git_clone_warning
from bloom.commands.release import perform_release
import time

disable_git_clone(True)
quiet_git_clone_warning(True)

repo_v = get_repository_version(organization, repository)
assert(repo_v)

import bloom
import bloom.summary
import bloom.commands.release

import os
pretend = False
for rosdistro in ['indigo', 'jade']:
    ros_v = get_release_version(rosdistro, repository_name)
    os.environ['BLOOM_TRACK'] = rosdistro
    if ros_v and repo_v != ros_v :
        print "run bloom for ", repository_name
        sys.stdout.flush()
        bloom.summary._summary_file = None
        bloom.commands.release._rosdistro_index_commit = None
        perform_release(repository=repository_name, track=rosdistro, distro=rosdistro,
                        new_track=None, interactive=None, pretend=pretend, pull_request_only=None, override_release_repository_url=None, override_release_repository_push_url=None)
        time.sleep(60)

exit(0)








