# Local Jenkins sandbox — verify the node-allocation fix

This spins up a throwaway Jenkins (1 controller + 1 SSH agent) to prove that the
fixed `runJob()` no longer schedules anything on the Jenkins controller (master).

## What's inside

- **controller** — Jenkins LTS, auto-configured via JCasC (`casc.yaml`), no setup wizard.
- **agent** — an SSH agent registered as node `DEV-USE1-ZEBRUNNER-SLAVE-01`
  (same label the client uses via `jenkinsNodeLabel`).
- Two pre-created pipeline jobs that mirror the library logic:
  - `node-alloc-BEFORE-fix` — old logic: a bootstrap `node('built-in')` block runs on the controller first.
  - `node-alloc-AFTER-fix` — fixed logic: the node is resolved first, so only the agent is used.

> Note: these two jobs reproduce the exact node-allocation *logic* of `runJob()`
> without the full Carina/Maven/reporting stack, so the result is fast and reliable.
> The `Zebrunner-CE` shared library is also pre-registered (pointing at the real
> GitHub repo, default version `2.3`) if you later want to run the real thing.

## Run it

1. Start **Docker Desktop** and wait until it's running.
2. From this folder:

   ```bash
   ./setup.sh
   ```

3. Open http://localhost:8080  (login: `admin` / `admin`).
4. Run **`node-alloc-BEFORE-fix`** → Build with Parameters → Build.
   In *Console Output* you'll see a line like `Running on Jenkins in ...` (the controller),
   then it switches to the agent.
5. Run **`node-alloc-AFTER-fix`** the same way. You'll see it go **straight to the agent**
   (`Running on DEV-USE1-ZEBRUNNER-SLAVE-01`) with **no controller line**. That's the fix.

## Clean up

```bash
docker compose down -v
```

Removes the containers and the Jenkins home volume. Delete this folder to remove everything.

## One nuance (important)

Every Jenkins pipeline has a tiny "flyweight" task that always lives on the controller — that's
unavoidable for *any* pipeline and is not what the client is complaining about. The client's
issue is the **heavyweight `node` block** that allocated a workspace/executor on the controller
(the `Running on Jenkins in /local/apps/jenkins/workspace/...` line). The fix removes *that*.
