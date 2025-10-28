#!/bin/bash
SCREEN="${1:-login}"
TYPE="${2:-authentication}"
SCENARIO="${3:-Test scenario}"

echo "Generating test for $SCREEN..."
echo "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/call\",\"params\":{\"name\":\"generate_test\",\"arguments\":{\"projectPath\":\"/Users/abhishekkumar/Documents/GitHub/automationtest\",\"screenName\":\"$SCREEN\",\"testType\":\"$TYPE\",\"testScenario\":\"$SCENARIO\"}}}" | node build/index.js | jq '.result.content[0].text' -r
