Quickstart App - Safe Install Instructions (Windows)
===============================================

This file documents a safe way to clean and reinstall node modules on Windows, and how to use the `safe-install` script added to this project.

Usage
-----
1) Open PowerShell as your usual user (elevated if you have permission issues) and navigate to the `quick_acg` directory:

```powershell
cd 'C:\Users\MukeshBishnoi\Downloads\Quickstart App-27112025-node.js\quick_acg'
```

2) Run the safe cleanup/install script:

```powershell
npm run safe-install
```

What the script does
--------------------
- Removes `node_modules` in the `quick_acg` folder and the parent folder (if present).
- Removes `package-lock.json` files to avoid lockfile incompatibilities when necessary.
- Cleans the npm cache and attempts to update npm to the latest version.
- Installs dependencies using `npm ci` if a `package-lock.json` exists, otherwise `npm install`.

Notes and troubleshooting
------------------------
- If there are still errors referencing `get-intrinsic` or another package, try running the install in verbose mode:

```powershell
npm install --verbose > npm-install.log 2>&1
```

and attach the `npm-install.log` or paste the final lines for support.

- If the repo is deep in a long path, try moving it closer to `C:\` to avoid Windows path length problems.
- If you use an antivirus or file sync service (e.g., OneDrive), temporarily disable it or add an exclusion for the project folder.
- This script intentionally avoids the destructive `test:win32` behavior in `package.json`. If you need that behavior, use:

```powershell
npm run test:win32:unsafe
```

Common issue: "Cannot find module 'moment'" (or similar)
------------------------------------------------------
- If you see an error like "Cannot find module 'moment'" when running `npm start` from the `quick_acg` directory, it typically means Node can't resolve modules from the project root because dependencies were installed only in `quick_acg/node_modules`.
- Fix options:
	- Install dependencies at the repository root (recommended):
		```powershell
		cd 'C:\path\to\Quickstart App-27112025-node.js'
		npm install
		```
	- If you already ran `npm install` in `quick_acg`, you can move the installed `node_modules` to the parent folder (not generally recommended):
		```powershell
		cd 'C:\path\to\Quickstart App-27112025-node.js\quick_acg'
		Move-Item -Path .\node_modules -Destination ..\node_modules -Force
		```
	- Re-run the safe-install script if you encounter npm/lockfile errors:
		```powershell
		npm run safe-install
		```
