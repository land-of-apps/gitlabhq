---
stage: Release
group: Progressive Delivery
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Feature Flags **(STARTER)**

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/7433) in GitLab 11.4.
> - [Moved](https://gitlab.com/gitlab-org/gitlab/-/issues/212318) to [GitLab Starter](https://about.gitlab.com/pricing/) in 13.4

With Feature Flags, you can deploy your application's new features to production in smaller batches.
You can toggle a feature on and off to subsets of users, helping you achieve Continuous Delivery.
Feature flags help reduce risk, allowing you to do controlled testing, and separate feature
delivery from customer launch.

<i class="fa fa-youtube-play youtube" aria-hidden="true"></i>
For an example of feature flags in action, see [GitLab for Deploys, Feature Flags, and Error Tracking](https://www.youtube.com/embed/5tw2p6lwXxo).

NOTE: **Note:**
The Feature Flags GitLab offer as a feature (described in this document) is not the same method
used for the [development of GitLab](../development/feature_flags/index.md).

## How it works

GitLab uses [Unleash](https://github.com/Unleash/unleash), a feature
toggle service.

By enabling or disabling a flag in GitLab, your application
can determine which features to enable or disable.

You can create feature flags in GitLab and use the API from your application
to get the list of feature flags and their statuses. The application must be configured to communicate
with GitLab, so it's up to developers to use a compatible client library and
[integrate the feature flags in your app](#integrate-feature-flags-with-your-application).

## Create a feature flag

To create and enable a feature flag:

1. Navigate to your project's **Operations > Feature Flags**.
1. Click the **New feature flag** button.
1. Enter a name that starts with a letter and contains only lowercase letters, digits, underscores (`_`),
   or dashes (`-`), and does not end with a dash (`-`) or underscore (`_`).
1. Enter a description (optional, 255 characters max).
1. Enter details about how the flag should be applied:
   - In GitLab 13.0 and earlier, add **Environment specs**. For each environment,
     include the **Status** (default enabled) and [**Rollout strategy**](#rollout-strategy-legacy)
     (defaults to **All users**).
   - In GitLab 13.1 and later, add Feature Flag [**Strategies**](#feature-flag-strategies).
     For each strategy, include the **Type** (defaults to [**All users**](#all-users))
     and **Environments** (defaults to all environments).
1. Click **Create feature flag**.

You can change these settings by clicking the **{pencil}** (edit) button
next to any feature flag in the list.

## Feature flag strategies

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/35555) in GitLab 13.0.
> - It was deployed behind a feature flag, disabled by default.
> - It became [enabled by default](https://gitlab.com/gitlab-org/gitlab/-/issues/214684) in GitLab 13.2.
> - It's recommended for production use.
> - It's enabled on GitLab.com.
> - For GitLab self-managed instances, a GitLab administrator can choose to [disable it](#enable-or-disable-feature-flag-strategies). **(CORE ONLY)**

You can apply a feature flag strategy across multiple environments, without defining
the strategy multiple times.

GitLab Feature Flags use [Unleash](https://unleash.github.io) as the feature flag
engine. In Unleash, there are [strategies](https://unleash.github.io/docs/activation_strategy)
for granular feature flag controls. GitLab Feature Flags can have multiple strategies,
and the supported strategies are:

- [All users](#all-users)
- [Percent of Users](#percent-of-users)
- [User IDs](#user-ids)
- [User List](#user-list)

Strategies can be added to feature flags when [creating a feature flag](#create-a-feature-flag),
or by editing an existing feature flag after creation by navigating to **Operations > Feature Flags**
and clicking **{pencil}** (edit).

### All users

Enables the feature for all users. It uses the [`default`](https://unleash.github.io/docs/activation_strategy#default)
Unleash activation strategy.

### Percent of Users

Enables the feature for a percentage of authenticated users. It uses the
[`gradualRolloutUserId`](https://unleash.github.io/docs/activation_strategy#gradualrolloutuserid)
Unleash activation strategy.

For example, set a value of 15% to enable the feature for 15% of authenticated users.

The rollout percentage can be from 0% to 100%.

NOTE: **Note:**
Stickiness (consistent application behavior for the same user) is guaranteed for logged-in users, but not anonymous users.

CAUTION: **Caution:**
If this strategy is selected, then the Unleash client **must** be given a user
ID for the feature to be enabled. See the [Ruby example](#ruby-application-example) below.

### User IDs

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/8240) in GitLab 12.2. [Updated](https://gitlab.com/gitlab-org/gitlab/-/issues/34363) to be defined per environment in GitLab 12.6.

Enables the feature for a list of target users. It is implemented
using the Unleash [`userWithId`](https://unleash.github.io/docs/activation_strategy#userwithid)
activation strategy.

Enter user IDs as a comma-separated list of values. For example,
`user@example.com, user2@example.com`, or `username1,username2,username3`, and so on.

NOTE: **Note:**
User IDs are identifiers for your application users. They do not need to be GitLab users.

CAUTION: **Caution:**
The Unleash client **must** be given a user ID for the feature to be enabled for
target users. See the [Ruby example](#ruby-application-example) below.

### User List

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/35930) in GitLab 13.1.

Enables the feature for lists of users created [in the Feature Flags UI](#create-a-user-list), or with the [Feature Flag User List API](../api/feature_flag_user_lists.md).
Similar to [User IDs](#user-ids), it uses the Unleash [`userWithId`](https://unleash.github.io/docs/activation_strategy#userwithid)
activation strategy.

It's not possible to *disable* a feature for members of a user list, but you can achieve the same
effect by enabling a feature for a user list that doesn't contain the excluded users.

For example:

- `Full-user-list` = `User1A, User1B, User2A, User2B, User3A, User3B, ...`
- `Full-user-list-excluding-B-users` = `User1A, User2A, User3A, ...`

#### Create a user list

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/13308) in GitLab 13.3.

To create a user list:

1. In your project, navigate to **Operations > Feature Flags**.
1. Click on **New list**.
1. Enter a name for the list.
1. Click **Create**.

You can view a list's User IDs by clicking the **{pencil}** (edit) button next to it.
When viewing a list, you can rename it by clicking the **Edit** button.

#### Add users to a user list

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/13308) in GitLab 13.3.

To add users to a user list:

1. In your project, navigate to **Operations > Feature Flags**.
1. Click on the **{pencil}** (edit) button next to the list you want to add users to.
1. Click on **Add Users**.
1. Enter the user IDs as a comma-separated list of values. For example,
   `user@example.com, user2@example.com`, or `username1,username2,username3`, and so on.
1. Click on **Add**.

#### Remove users from a user list

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/13308) in GitLab 13.3.

To remove users from a user list:

1. In your project, navigate to **Operations > Feature Flags**.
1. Click on the **{pencil}** (edit) button next to the list you want to change.
1. Click on the **{remove}** (remove) button next to the ID you want to remove.

### Enable or disable feature flag strategies

This feature is under development, but is ready for production use. It's
deployed behind a feature flag that is **enabled by default**.
[GitLab administrators with access to the GitLab Rails console](../administration/feature_flags.md)
can disable it for your instance.

To disable it:

```ruby
Feature.disable(:feature_flags_new_version)
```

To enable it:

```ruby
Feature.enable(:feature_flags_new_version)
```

## Rollout strategy (legacy)

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/8240) in GitLab 12.2.
> - [Made read-only](https://gitlab.com/gitlab-org/gitlab/-/issues/220228) in GitLab 13.4.

In GitLab 13.0 and earlier, the **Rollout strategy** setting affects which users will experience
the feature as enabled. Choose the percentage of users that the feature will be enabled
for. The rollout strategy will have no effect if the environment spec is disabled.

It can be set to:

- All users
- [Percent of users](#percent-of-users)
  - Optionally, you can click the **Include additional user IDs** checkbox and add a list
    of specific users IDs to enable the feature for.
- [User IDs](#user-ids)

## Disable a feature flag for a specific environment

In [GitLab 13.0 and earlier](https://gitlab.com/gitlab-org/gitlab/-/issues/8621),
to disable a feature flag for a specific environment:

1. Navigate to your project's **Operations > Feature Flags**.
1. For the feature flag you want to disable, click the Pencil icon.
1. To disable the flag:

   - In GitLab 13.0 and earlier: Slide the Status toggle for the environment. Or, to delete the
     environment spec, on the right, click the **Remove (X)** icon.
   - In GitLab 13.1 and later: For each strategy it applies to, under **Environments**, delete the environment.

1. Click **Save changes**.

## Disable a feature flag for all environments

To disable a feature flag for all environments:

1. Navigate to your project's **Operations > Feature Flags**.
1. For the feature flag you want to disable, slide the Status toggle to **Disabled**.

The feature flag is displayed on the **Disabled** tab.

## Integrate feature flags with your application

To use feature flags with your application, get access credentials from GitLab.
Then prepare your application with a client library.

### Get access credentials

To get the access credentials that your application needs to communicate with GitLab:

1. Navigate to your project's **Operations > Feature Flags**.
1. Click the **Configure** button to view the following:
   - **API URL**: URL where the client (application) connects to get a list of feature flags.
   - **Instance ID**: Unique token that authorizes the retrieval of the feature flags.
   - **Application name**: The name of the *environment* the application runs in
     (not the name of the application itself).

     For example, if the application runs for a production server, the **Application name**
     could be `production` or similar. This value is used for the environment spec evaluation.

NOTE: **Note:**
The meaning of these fields might change over time. For example, we are not sure
if **Instance ID** will be single token or multiple tokens, assigned to the
**Environment**. Also, **Application name** could describe the version of
application instead of the running environment.

### Choose a client library

GitLab implements a single backend that is compatible with Unleash clients.

With the Unleash client, developers can define, in the application code, the default values for flags.
Each feature flag evaluation can express the desired outcome if the flag isn't present in the
provided configuration file.

Unleash currently [offers many SDKs for various languages and frameworks](https://github.com/Unleash/unleash#client-implementations).

### Feature flags API information

For API content, see:

- [Feature Flags API](../api/feature_flags.md)
- [Feature Flag Specs API](../api/feature_flag_specs.md) (Deprecated and [scheduled for removal in GitLab 14.0](https://gitlab.com/gitlab-org/gitlab/-/issues/213369).)
- [Feature Flag User Lists API](../api/feature_flag_user_lists.md)
- [Legacy Feature Flags API](../api/feature_flags_legacy.md)

### Golang application example

Here's an example of how to integrate feature flags in a Golang application:

```golang
package main

import (
    "io"
    "log"
    "net/http"

    "github.com/Unleash/unleash-client-go"
)

type metricsInterface struct {
}

func init() {
    unleash.Initialize(
        unleash.WithUrl("https://gitlab.com/api/v4/feature_flags/unleash/42"),
        unleash.WithInstanceId("29QmjsW6KngPR5JNPMWx"),
        unleash.WithAppName("production"), // Set to the running environment of your application
        unleash.WithListener(&metricsInterface{}),
    )
}

func helloServer(w http.ResponseWriter, req *http.Request) {
    if unleash.IsEnabled("my_feature_name") {
        io.WriteString(w, "Feature enabled\n")
    } else {
        io.WriteString(w, "hello, world!\n")
    }
}

func main() {
    http.HandleFunc("/", helloServer)
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

### Ruby application example

Here's an example of how to integrate feature flags in a Ruby application.

The Unleash client is given a user ID for use with a **Percent rollout (logged in users)** rollout strategy or a list of **Target Users**.

```ruby
#!/usr/bin/env ruby

require 'unleash'
require 'unleash/context'

unleash = Unleash::Client.new({
  url: 'http://gitlab.com/api/v4/feature_flags/unleash/42',
  app_name: 'production', # Set to the running environment of your application
  instance_id: '29QmjsW6KngPR5JNPMWx'
})

unleash_context = Unleash::Context.new
# Replace "123" with the ID of an authenticated user.
# Note that the context's user ID must be a string:
# https://unleash.github.io/docs/unleash_context
unleash_context.user_id = "123"

if unleash.is_enabled?("my_feature_name", unleash_context)
  puts "Feature enabled"
else
  puts "hello, world!"
end
```

## Feature Flag Related Issues **(PREMIUM)**

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/36617) in GitLab 13.2.
> - It's deployed behind a feature flag, enabled by default.
> - It's enabled on GitLab.com.
> - It can't be enabled or disabled per-project
> - It's recommended for production use.
> - For GitLab self-managed instances, GitLab administrators can opt to disable it.

You can link related issues to a feature flag. In the **Linked issues** section, click the `+` button and input the issue reference number or the full URL of the issue.

This feature is similar to the [related issues](../user/project/issues/related_issues.md) feature.

### Enable or disable Feature Flag Related Issues **(CORE ONLY)**

Feature Flag Related Issues is under development but ready for production use.
It is deployed behind a feature flag that is **enabled by default**.
[GitLab administrators with access to the GitLab Rails console](../administration/feature_flags.md)
can opt to disable it for your instance.

To disable it:

```ruby
Feature.disable(:feature_flags_issue_links)
```

To enable it:

```ruby
Feature.enable(:feature_flags_issue_links)
```
