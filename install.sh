

cd "$(dirname "${0}")" || exit
curdirec="$(pwd)"

if [ -f "proj-info/proj-name.txt" ]; then
  fildesnom="$(cat "proj-info/proj-name.txt")"
  echo "Project Identified: ${fildesnom}:"
else
  (
    echo
    echo PROJECT NAME NOT FOUND
    echo "$(pwd)/proj-info/proj-name.txt"
    echo
  ) > /dev/stderr
  exit 3
fi


rm -rf tmp
mkdir -p tmp
(
  echo "#! $(which perl)"
  echo "use strict;"
  echo "my \$resloc = \"${curdirec}\";"
  echo "# line 1 \"${curdirec}/outer-wrap.qpl-then\""
  cat outer-wrap.qpl
) > tmp/${fildesnom}
chmod 755 tmp/${fildesnom}
perl -c tmp/${fildesnom} || exit 2

destina="${HOME}/bin"
# Allow overriding of default:
if [ -f "ins-opt-code/dir-of-install.txt" ]; then
  destina="$(cat ins-opt-code/dir-of-install.txt)"
fi

cp "tmp/${fildesnom}" "${destina}/."
chmod 755 "${destina}/${fildesnom}"

if [ -f "after-install.sh" ]; then
  exec sh after-install.sh
fi

# Prepare environment for extra compilation instructions:

MY_DESTINA_BIN="${destina}"
export MY_DESTINA_BIN

if [ -f "extra-install.sh" ]; then
  exec sh extra-install.sh
fi





