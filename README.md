# Running

Clone the repository. Install dependencies with `npm`:

```
npm install
```

Make sure akiban server is running. Configuration can be specified in
the `config.coffee` file.

Create the schema in Akiban before running:

```
psql -h localhost -p 15432 test -f schema.sql
```
