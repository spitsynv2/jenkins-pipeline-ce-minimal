# pipeline-ce local test sandbox

Minimal local Jenkins setup for exercising changes to the [Zebrunner CE shared library](https://github.com/spitsynv2/pipeline-ce) before pushing them upstream or into a client environment.

Spins up a throwaway Jenkins controller plus one SSH agent, pre-wired with the same shared library, node labels, and config-file shape a real Zebrunner deployment expects.

## What's inside

- **controller** — Jenkins LTS (JDK 17), auto-configured via JCasC (`casc.yaml`), no setup wizard.
- **agent** — SSH agent registered as `DEV-USE1-ZEBRUNNER-SLAVE-01` with the `maven` label (matches typical `jenkinsNodeLabel` usage).
- **Zebrunner-CE shared library** — registered globally; by default it points at [spitsynv2/pipeline-ce](https://github.com/spitsynv2/pipeline-ce).
- **`Register-Repository` job** — the only hand-run job. It clones a Carina/TestNG repo, scans `src/test/resources/**/*.xml`, and auto-generates one pipeline job per suite via the library's `TestNG.onPush()` flow.

## Point at your pipeline-ce changes

Edit `casc.yaml` and set your fork branch/tag in three places:

1. `jenkins.globalNodeProperties.env.ZEBRUNNER_VERSION`
2. `unclassified.globalLibraries.libraries[0].defaultVersion`
3. `unclassified.globalLibraries.libraries[0].retriever.modernSCM.scm.git.remote` — use `https://github.com/spitsynv2/pipeline-ce.git` (or your fork URL)

To test against a Carina repo, update the default `repoUrl` parameter on the `Register-Repository` job in the same file.

## Run it

1. Start **Docker Desktop** and wait until it is running.
2. From this folder:

   ```bash
   ./setup.sh
   ```

   On first run this generates an SSH keypair under `keys/` and builds the controller image.

3. Open http://localhost:8080 (login: `admin` / `admin`).
4. Run **Register-Repository** → Build with Parameters → set your repo URL and branch → Build.
5. Jenkins creates one job per discovered TestNG suite. Run any generated job to exercise the library end-to-end on the local agent.

## Optional: use a real EC2 agent

`casc.yaml` includes a commented EC2 node block. Comment out the local Docker agent, fill in the EC2 host/user/key placeholders, and add `EC2_PRIVATE_KEY` to `.env` if you need to reproduce client-side node behavior on AWS instead of the bundled container.

## Clean up

```bash
docker compose down -v
```

Removes the containers and the Jenkins home volume. Delete this folder to remove everything else (including generated keys).
