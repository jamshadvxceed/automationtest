#!/bin/bash

PROJECT_PATH="/Users/abhishekkumar/Documents/GitHub/automationtest"

# Test 1: Analyze app
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"analyze_flutter_app","arguments":{"projectPath":"'$PROJECT_PATH'"}}}' | node build/index.js

echo ""
echo "---"
echo ""

# Test 2: Generate test
echo '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"generate_test","arguments":{"projectPath":"'$PROJECT_PATH'","screenName":"login","testType":"authentication","testScenario":"Valid login test"}}}' | node build/index.js
