# Contributing

Pull requests are generally welcome, and require one +1. They also require a green build on Travis.

## Xcode templates

PRs will not be accepted if you have not set up your templates. You can find the Zendesk Xcode templates found [in this repository](https://github.com/zendesk/mobile_xcode_templates#usage).

## i18n

i18n contributions are typically done by the i18n team. A +1 from a member of the SDK team is not
required, but please cc @zendesk/adventure so that we know what is being done.

## Changing the journey

We do not welcome any changes to the flow of the UI unless they have come from the product team.

## Contributions from outside the team

If you are not a member of @zendesk/adventure then you need a +1 from a member of the team.

## Deprecating

Deprecation is required when you want to remove a class or method, or change signatures. Occasionally
breaking changes are permitted, but this must be approved by a DevLead.

## Testing

Unit tests are required if you are refactoring or committing new code. Instrumentation tests are
desirable, but not mandatory at this time.