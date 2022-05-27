#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import os


def main():
    with open(os.path.expanduser("~/klipper_logs/klippy.log")) as ifp:
        last_start = None
        line = ifp.readline()
        while line:
            if line.startswith("===== Config file ====="):
                last_start = ifp.tell()

            line = ifp.readline()

        assert last_start is not None, "didn't find start of config file"
        ifp.seek(last_start)

        line = ifp.readline()
        while not line.startswith("======================="):
            print(line, end="")
            line = ifp.readline()


if __name__ == "__main__":
    main()
