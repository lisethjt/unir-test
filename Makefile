.PHONY: all $(MAKECMDGOALS)

PWD := $(CURDIR)

build:
	docker build -t calculator-app .

run:
	docker run --rm --volume "${PWD}:/opt/calc" --env PYTHONPATH=/opt/calc -w /opt/calc calculator-app:latest python -B app/calc.py

server:
	docker run --rm --volume "${PWD}:/opt/calc" --name apiserver --network-alias api --env PYTHONPATH=/opt/calc --env FLASK_APP=app/api.py -p 8080:8080 -w /opt/calc calculator-app:latest flask run --host=0.0.0.0 --port 8080

interactive:
	docker run -ti --rm --volume "${PWD}:/opt/calc" --env PYTHONPATH=/opt/calc  -w /opt/calc calculator-app:latest bash

test-unit:
	docker run --rm --volume "${PWD}:/opt/calc" --env PYTHONPATH=/opt/calc -w /opt/calc calculator-app:latest pytest --cov --cov-report=xml:results/coverage.xml --cov-report=html:results/coverage --junit-xml=results/unit_result.xml -m unit || echo Ignored error
	docker run --rm --volume "${PWD}:/opt/calc" --env PYTHONPATH=/opt/calc -w /opt/calc calculator-app:latest junit2html results/unit_result.xml results/unit_result.html

test-behavior:
	docker run --rm --volume "${PWD}:/opt/calc" --env PYTHONPATH=/opt/calc -w /opt/calc calculator-app:latest behave --junit --junit-directory results/  --tags ~@wip test/behavior/
	docker run --rm --volume "${PWD}:/opt/calc" --env PYTHONPATH=/opt/calc -w /opt/calc calculator-app:latest bash test/behavior/junit-reports.sh
	
test-api:
	docker network create calc-test-api || echo Ignored error
	docker stop apiserver || echo Ignored error
	docker rm --force apiserver || echo Ignored error
	docker run -d --rm --volume "${PWD}:/opt/calc" --network calc-test-api --name apiserver --network-alias api --env PYTHONPATH=/opt/calc --env FLASK_APP=app/api.py -p 8080:8080 -w /opt/calc calculator-app:latest flask run --host=0.0.0.0 --port 8080
	docker run --rm --volume "${PWD}:/opt/calc" --network calc-test-api --env PYTHONPATH=/opt/calc --env BASE_URL=http://api:8080/ -w /opt/calc calculator-app:latest pytest --junit-xml=results/api_result.xml -m api  || echo Ignored error
	docker run --rm --volume "${PWD}:/opt/calc" --env PYTHONPATH=/opt/calc -w /opt/calc calculator-app:latest junit2html results/api_result.xml results/api_result.html
	docker stop apiserver || echo Ignored error
	docker rm --force apiserver || echo Ignored error
	docker network rm calc-test-api

test-e2e:
	docker network create calc-test-e2e || echo Ignored error
	docker stop apiserver || echo Ignored error
	docker rm --force apiserver || echo Ignored error
	docker stop calc-web || echo Ignored error
	docker rm --force calc-web || echo Ignored error
	docker run -d --rm --volume "${PWD}:/opt/calc" --network calc-test-e2e --env PYTHONPATH=/opt/calc --name apiserver --network-alias api --env FLASK_APP=app/api.py -p 8080:8080 -w /opt/calc calculator-app:latest flask run --host=0.0.0.0 --port 8080
	docker run -d --rm --volume "${PWD}/web:/usr/share/nginx/html" --volume "${PWD}/web/constants.test.js:/usr/share/nginx/html/constants.js" --volume "${PWD}/web/nginx.conf:/etc/nginx/conf.d/default.conf" --network calc-test-e2e --name calc-web -p 80:80 nginx
	docker run --rm --volume "${PWD}/test/e2e/cypress.json:/cypress.json" --volume "${PWD}/test/e2e/cypress:/cypress" --volume "${PWD}/results:/results"  --network calc-test-e2e cypress/included:4.9.0 --browser chrome || echo Ignored error
	docker rm --force apiserver
	docker rm --force calc-web
	docker run --rm --volume "${PWD}:/opt/calc" --env PYTHONPATH=/opt/calc -w /opt/calc calculator-app:latest junit2html results/cypress_result.xml results/cypress_result.html
	docker network rm calc-test-e2e

test-e2e-wiremock:
	docker network create calc-test-e2e-wiremock || echo Ignored error
	docker stop apiwiremock || echo Ignored error
	docker rm --force apiwiremock || echo Ignored error
	docker stop calc-web || echo Ignored error
	docker rm --force calc-web || echo Ignored error
	docker run -d --rm --name apiwiremock --network-alias api --volume "${PWD}/test/wiremock/stubs:/home/wiremock" --network calc-test-e2e-wiremock -p 8080:8080 -p 8443:8443 calculator-wiremock
	docker run -d --rm --volume "${PWD}/web:/usr/share/nginx/html" --volume "${PWD}/web/constants.wiremock.js:/usr/share/nginx/html/constants.js" --volume "${PWD}/web/nginx.conf:/etc/nginx/conf.d/default.conf" --network calc-test-e2e-wiremock --name calc-web -p 80:80 nginx
	docker run --rm --volume "${PWD}/test/e2e/cypress.json:/cypress.json" --volume "${PWD}/test/e2e/cypress:/cypress" --volume "${PWD}/results:/results" --network calc-test-e2e-wiremock cypress/included:4.9.0 --browser chrome || echo Ignored error
	docker rm --force apiwiremock
	docker rm --force calc-web
	docker run --rm --volume "${PWD}:/opt/calc" --env PYTHONPATH=/opt/calc -w /opt/calc calculator-app:latest junit2html results/cypress_result.xml results/cypress_result.html
	docker network rm calc-test-e2e-wiremock

run-web:
	docker run --rm --volume "${PWD}/web:/usr/share/nginx/html"  --volume "${PWD}/web/constants.local.js:/usr/share/nginx/html/constants.js" --volume "${PWD}/web/nginx.conf:/etc/nginx/conf.d/default.conf" --name calc-web -p 80:80 nginx

stop-web:
	docker stop calc-web

start-sonar-server:
	docker network create calc-sonar || echo Ignored error
	docker run -d --rm --stop-timeout 60 --network calc-sonar --name sonarqube-server -p 9000:9000 --volume "${PWD}/sonar/data:/opt/sonarqube/data" --volume "${PWD}/sonar/logs:/opt/sonarqube/logs" sonarqube:8.3.1-community

stop-sonar-server:
	docker stop sonarqube-server
	docker network rm calc-sonar || echo Ignored error

start-sonar-scanner:
	docker run --rm --network calc-sonar -v "${PWD}:/usr/src" sonarsource/sonar-scanner-cli

pylint:
	docker run --rm --volume "${PWD}:/opt/calc" --env PYTHONPATH=/opt/calc -w /opt/calc calculator-app:latest pylint app/ | tee results/pylint_result.txt

build-wiremock:
	docker build -t calculator-wiremock -f test/wiremock/Dockerfile test/wiremock/

start-wiremock:
	docker run -d --rm --name calculator-wiremock --volume "${PWD}/test/wiremock/stubs:/home/wiremock" -p 8080:8080 -p 8443:8443 calculator-wiremock

stop-wiremock:
	docker stop calculator-wiremock || echo Ignored error

ZAP_API_KEY := my_zap_api_key
ZAP_API_URL := http://zap-node:8080/
ZAP_TARGET_URL := http://calc-web/
zap-scan:
	docker network create calc-test-zap || echo Ignored error
	docker run -d --rm --network calc-test-zap --volume "${PWD}:/opt/calc" --name apiserver --network-alias api --env PYTHONPATH=/opt/calc --env FLASK_APP=app/api.py -p 8080:8080 -w /opt/calc calculator-app:latest flask run --host=0.0.0.0 --port 8080
	docker run -d --rm --network calc-test-zap --volume "${PWD}/web:/usr/share/nginx/html"  --volume "${PWD}/web/constants.test.js:/usr/share/nginx/html/constants.js" --volume "${PWD}/web/nginx.conf:/etc/nginx/conf.d/default.conf" --name calc-web -p 80:80 nginx
	docker run -d --rm --network calc-test-zap --name zap-node -u zap -i ghcr.io/zaproxy/zaproxy:stable zap.sh -daemon -host 0.0.0.0 -port 8080 -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true -config api.key=$(ZAP_API_KEY)
	ping 127.0.0.1 -n 11 > NUL
	docker run --rm --volume "${PWD}:/opt/calc" --network calc-test-zap --env PYTHONPATH=/opt/calc --env ZAP_API_KEY=$(ZAP_API_KEY) --env ZAP_API_URL=$(ZAP_API_URL) --env TARGET_URL=$(ZAP_TARGET_URL) -w /opt/calc calculator-app:latest pytest --junit-xml=results/sec_result.xml -m security  || echo Ignored error
	docker run --rm --volume "${PWD}:/opt/calc" --env PYTHONPATH=/opt/calc -w /opt/calc calculator-app:latest junit2html results/sec_result.xml results/sec_result.html
	docker stop apiserver || echo Ignored error
	docker stop calc-web || echo Ignored error
	docker stop zap-node || echo Ignored error
	docker network rm calc-test-zap || echo Ignored error

build-jmeter:
	docker build -t calculator-jmeter -f test/jmeter/Dockerfile test/jmeter

start-jmeter-record:
	docker network create calc-test-jmeter || echo Ignored error
	docker run -d --rm --network calc-test-jmeter --volume "${PWD}:/opt/calc" --name apiserver --network-alias apiserver --env PYTHONPATH=/opt/calc --env FLASK_APP=app/api.py -p 5000:5000 -w /opt/calc calculator-app:latest flask run --host=0.0.0.0
	docker run -d --rm --network calc-test-jmeter --volume "${PWD}/web:/usr/share/nginx/html"  --volume "${PWD}/web/constants.test.js:/usr/share/nginx/html/constants.js" --volume "${PWD}/web/nginx.conf:/etc/nginx/conf.d/default.conf" --name calc-web -p 80:80 nginx

stop-jmeter-record:
	docker stop apiserver || echo Ignored error
	docker stop calc-web || echo Ignored error
	docker network rm calc-test-jmeter || echo Ignored error


JMETER_RESULTS_FILE := results/jmeter_results.csv
JMETER_REPORT_FOLDER := results/jmeter/
jmeter-load:
	rm -f $(JMETER_RESULTS_FILE)
	rm -rf $(JMETER_REPORT_FOLDER)
	docker network create calc-test-jmeter || echo Ignored error
	docker run -d --rm --network calc-test-jmeter --volume "${PWD}:/opt/calc" --name apiserver --network-alias apiserver --env PYTHONPATH=/opt/calc --env FLASK_APP=app/api.py -p 5000:5000 -w /opt/calc calculator-app:latest flask run --host=0.0.0.0
	sleep 5
	docker run --rm --network calc-test-jmeter --volume "${PWD}:/opt/jmeter" -w /opt/jmeter calculator-jmeter jmeter -n -t test/jmeter/jmeter-plan.jmx -l results/jmeter_results.csv -e -o results/jmeter/
	docker stop apiserver || echo Ignored error
	docker network rm calc-test-zap || echo Ignored error

