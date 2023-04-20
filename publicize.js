import { test, expect } from '@playwright/test';
import * as playwright from 'playwright';

import * as fs from "fs";
const data = fs.readFileSync("packages.txt", "utf8");
const packages = data.split("\n").map(p => p.split("/").slice(-1)[0].trim());

// first run chromium  --remote-debugging-port=9222 --user-data-dir=/tmp/n
// log in to github manually

const wsUrl = (await fetch("http://127.0.0.1:9222/json/version").then(r => r.json())).webSocketDebuggerUrl
const browser = await playwright.chromium.connectOverCDP(wsUrl);
const defaultContext = browser.contexts()[0];
const page = defaultContext.pages()[0];
  for (const p of packages) {
    console.log("p", p);
    await page.goto('https://github.com/users/jmandel/packages/npm/'+p+'/settings');
    await page.waitForLoadState("networkidle");
    const isCurrentlyPrivate = await page.isVisible(":text('currently private')");
    if (!isCurrentlyPrivate) {
      continue;
    }
    await page.getByRole('button', { name: 'Change visibility' }).click();
    await page.getByLabel('Public\n              Make this package visible to anyone.').check();
    await page.getByRole('textbox', { name: 'Type in the name of the package to confirm.' }).fill(p);
    await page.getByRole('button', { name: 'I understand the consequences, change package visibility.' }).click();
    await page.waitForSelector(":text('currently public')");
  }
