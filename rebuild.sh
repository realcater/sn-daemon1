docker stop postgres
docker rm postgres
docker run --name postgres -e POSTGRES_DB=vapor \
  -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password \
  -p 5432:5432 -d postgres

docker stop postgres-test
docker rm postgres-test
docker run --name postgres-test -e POSTGRES_DB=vapor-test \
-e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password \
-p 5433:5432 -d postgres
