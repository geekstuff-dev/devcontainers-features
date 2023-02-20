#!/bin/sh

cat > /usr/local/bin/xdg-open << 'EOF'
#!/bin/sh

exec $BROWSER "$1"
EOF
chmod ugo+rx /usr/local/bin/xdg-open

cat > /usr/local/bin/cmd.exe << 'EOF'
#!/bin/sh

exec $BROWSER "$(echo $3 | sed 's|\^&|\&|g')"
EOF
chmod ugo+rx /usr/local/bin/cmd.exe

out "[] xdg-open and cmd.exe browser wrapper created"
