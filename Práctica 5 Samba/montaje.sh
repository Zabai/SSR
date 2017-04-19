#!/bin/bash

user=$1
resource=$2
mountPath=$3

server="ZabaiEstacion.red2.redes.dis.ulpgc.es"

mount -t cifs -o username="$user" //"$server"/"$resource" "$mountPath"
cd "$mountPath"
