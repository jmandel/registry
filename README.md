# FHIR Registry Mirror

```
./setup.sh
deno run --allow-all mkval.ts cruft/ > allvs.ndjson
```
## Some analysis examples

create table allvs as (SELECT * FROM read_ndjson_auto('allvs.ndjson', maximum_object_size = 99999999, sample_size=9999999));

create table vs as (
select r1.* from allvs r1 join (
  select  max(id) as id, url, max(version) as version from allvs r2 group by url) r2
on r1.id=r2.id and r1.version=r2.version
);

select system, count(*) from (select unnest(r.compose.include).system from vs) group by s order by 2 desc limit 100;

