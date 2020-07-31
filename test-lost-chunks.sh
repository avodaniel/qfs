#!/usr/bin/env bash

set -xo pipefail

( cd build/debug/qfstest/meta && /root/build/debug/src/cc/meta/metaserver /root/build/debug/qfstest/meta/MetaServer-recovery.prp >/tmp/metaserver-drf.out 2>/tmp/metaserver-drf.err & echo "meta: $!" )

sleep 5;

for x in /root/build/debug/qfstest/chunk/2040?; do ( cd "$x" && /root/build/debug/bin/chunkserver ChunkServer-recovery.prp >"/tmp/chunkserver-drf-$(basename $x).out" 2>"/tmp/chunkserver-drf-$(basename $x).err" & echo "chunk: $!" ); done

/root/build/debug/bin/tools/qfsadmin  -s 127.0.0.1 -p 20200 -f /root/build/debug/qfstest/clientroot.prp ping
/root/build/debug/bin/tools/qfsadmin  -s 127.0.0.1 -p 20200 -f /root/build/debug/qfstest/clientroot.prp upservers

/root/build/debug/bin/tools/qfs  -D fs.glob=0 -cfg /root/build/debug/qfstest/client.prp -mkdir qfs://127.0.0.1:20200/user/faramir/recoverytest
/root/build/debug/bin/tools/qfs  -D fs.glob=0 -cfg /root/build/debug/qfstest/client.prp -ls qfs://127.0.0.1:20200/user/faramir/recoverytest

for x in {000..025}; do
	/root/build/debug/bin/devtools/rand-sfmt -g $((10*1024*1024)) 1234 |
		/root/build/debug/bin/tools/qfs  -D fs.glob=0 -cfg /root/build/debug/qfstest/client.prp -put - "qfs://127.0.0.1:20200/user/faramir/recoverytest/abc-$x.xyz"
done

/root/build/debug/bin/tools/qfsfileenum  -s 127.0.0.1 -p 20200 -c /root/build/debug/qfstest/client.prp -f /user/faramir/recoverytest/abc-010.xyz
/root/build/debug/bin/tools/qfsfileenum  -s 127.0.0.1 -p 20200 -c /root/build/debug/qfstest/client.prp -f /user/faramir/recoverytest/abc-020.xyz
/root/build/debug/bin/tools/qfsfileenum  -s 127.0.0.1 -p 20200 -c /root/build/debug/qfstest/client.prp -f /user/faramir/recoverytest/abc-021.xyz
/root/build/debug/bin/tools/qfsfileenum  -s 127.0.0.1 -p 20200 -c /root/build/debug/qfstest/client.prp -f /user/faramir/recoverytest/abc-022.xyz
/root/build/debug/bin/tools/qfsfileenum  -s 127.0.0.1 -p 20200 -c /root/build/debug/qfstest/client.prp -f /user/faramir/recoverytest/abc-023.xyz

/root/build/debug/bin/tools/qfsadmin  -s 127.0.0.1 -p 20200 -f /root/build/debug/qfstest/clientroot.prp ping
/root/build/debug/bin/tools/qfsadmin  -s 127.0.0.1 -p 20200 -f /root/build/debug/qfstest/clientroot.prp upservers


/root/build/debug/bin/qfsfsck  -s 127.0.0.1 -p 20200 -c /root/build/debug/qfstest/client.prp

: >/root/build/debug/qfstest/chunk/20400/kfschunk/evacuate

/root/build/debug/bin/tools/qfsadmin  -s 127.0.0.1 -p 20200 -f /root/build/debug/qfstest/clientroot.prp ping
/root/build/debug/bin/tools/qfsadmin  -s 127.0.0.1 -p 20200 -f /root/build/debug/qfstest/clientroot.prp upservers

for x in {0..100}; do
	/root/build/debug/bin/qfsfsck  -s 127.0.0.1 -p 20200 -c /root/build/debug/qfstest/client.prp
	ls -la /root/build/debug/qfstest/chunk/20400/kfschunk/*evac*
	/root/build/debug/bin/tools/qfsadmin  -s 127.0.0.1 -p 20200 -f /root/build/debug/qfstest/clientroot.prp ping
	/root/build/debug/bin/tools/qfsadmin  -s 127.0.0.1 -p 20200 -f /root/build/debug/qfstest/clientroot.prp upservers

	sleep 1
done

ls -la build/*/qfstest/chunk/*/kfschunk*
killall chunkserver
killall metaserver

exit 0
