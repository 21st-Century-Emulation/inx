docker build -q -t inx .
docker run --rm --name inx -d -p 8080:8080 inx

sleep 5

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":3,"state":{"a":10,"b":255,"c":255,"d":5,"e":5,"h":0,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":1,"stackPointer":2,"cycles":0}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"id":"abcd", "opcode":3,"state":{"a":10,"b":0,"c":0,"d":5,"e":5,"h":0,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":1,"stackPointer":2,"cycles":5}}'

docker kill inx

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mINX Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mINX Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi