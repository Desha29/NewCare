# NewCare project instructions

- Use feature-first data and presentation folders; Cubit for state management.
- Do not create entities, a domain layer, or use-case classes.
- Split screens into focused widgets; reuse core UI components.
- All interface text belongs in English and Arabic ARB files. Support RTL and LTR.
- The operational workflow has no shifts. Preserve historical serialized shift data without restoring shift controls.
- Procedures are names only; do not add catalogue prices or supplies back to the current UI.
- Enter each case total manually. Compute outstanding balance from its initial and later receipts; changing the total must not rewrite receipts or go below the amount already collected.
- Use "الخوارج" for expenses in Arabic. Drawer custody handovers are independent of shifts and record counted cash and discrepancies.
- Outgoings have two primary UI categories: "خوارج المركز" and "خوارج أشخاص". Advances are a purpose under person outgoings; never restore a standalone external-person-advance category. Preserve legacy stored kinds and classify through the model's category helpers.
- Preserve the official logo aspect ratio and use locally bundled Cairo.
- Never commit patient data, credentials, generated builds, or local configuration.
- Do not create any Git commits unless the user explicitly changes this instruction.
- GitHub access must use the connected MCP tools; do not use browser workarounds.
- Production authentication and synchronization must not be claimed in local preview mode.
- Verify with flutter analyze, flutter test, and flutter build web.

