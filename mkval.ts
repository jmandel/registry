
// value_set_finder.ts
import { walk } from "https://deno.land/std/fs/mod.ts";

async function main() {
  if (Deno.args.length !== 2) {
    console.error("Usage: deno run --allow-read value_set_finder.ts [resource] [directory]");
    Deno.exit(1);
  }

  const resourceType = Deno.args[0];
  const dirPath = Deno.args[1];

  for await (const entry of walk(dirPath, { match: [new RegExp(resourceType + ".*\.json$")] })) {
    if (entry.isFile) {
      try {
        const jsonContent = await Deno.readTextFile(entry.path);
        const jsonObject = JSON.parse(jsonContent);
        if (jsonObject?.resourceType !== resourceType) {
            console.error("No js", jsonObject.resourceType);
            continue;
        }
        const ndjsonLine = JSON.stringify(jsonObject);
        console.log(ndjsonLine);
      } catch (error) {
        console.error(`Error processing file ${entry.path}:`, error);
      }
    }
  }
}

main();
