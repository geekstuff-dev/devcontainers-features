#!/bin/sh

cat > /usr/local/bin/xdg-open << 'EOF'
#!/bin/sh

exec $BROWSER "$1"
EOF

chmod +x /usr/local/bin/xdg-open

out "[] xdg-open browser wrapper created"
