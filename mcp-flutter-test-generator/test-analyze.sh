#!/bin/bash
echo "Analyzing Flutter app..."
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"analyze_flutter_app","arguments":{"projectPath":"/Users/abhishekkumar/Documents/GitHub/automationtest"}}}' | node build/index.js | jq '.result.content[0].text' -r
