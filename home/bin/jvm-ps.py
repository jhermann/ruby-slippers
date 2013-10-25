#! /usr/bin/env python
# -*- coding: utf-8 -*-
# pylint: disable=
""" List running JVMs on a POSIX system.

    Assumptions:
        * We're on a POSIX system with a working 'lsof'
        * JVMs live in "/usr/lib/jvm/"
"""
import subprocess
from collections import defaultdict


def run():
    """mainloop"""
    # TODO: allow lsof field selection via option
    fields = "cL"
    fields_fmt = "{2:15.15s} {1}"

    lsof_cmd = "lsof -F {0}n +D /usr/lib/jvm || echo '*** Ignored lsof error!\\n' >&2".format(fields)
    rawdata = subprocess.check_output(lsof_cmd, shell=True)
    data = defaultdict(set)
    memo = {}

    for field in rawdata.splitlines():
        kind, value = field[0], field[1:]
        memo[kind] = value
        if kind == 'n' and "/jre/" in value:
            jvm = value.split('/')[4]
            entry = [memo[i] for i in 'p'+fields]
            entry[0] = int(entry[0])
            data[jvm].add(tuple(entry))

    for jvm, processes in sorted(data.iteritems()):
        print("JVM {0}".format(jvm))
        for process in sorted(processes):
            print(("    {0:>5d} " + fields_fmt).format(*process))


if __name__ == "__main__":
    run()
