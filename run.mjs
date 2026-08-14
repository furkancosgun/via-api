import { execFileSync } from "child_process";

const program = process.env.PROGRAM || "zhello_world";
execFileSync(process.execPath, ["--expose-gc", `output/${program}.prog.mjs`], { stdio: "inherit" });
