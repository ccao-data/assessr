
# assessR

The goal of assessR is to manage, distribute, and version control commonly-used
CCAO assessment functions.

## Installation

You can install the released version of assessR directly from GitLab, but you'll 
first need to generate an authorization token by following
[these steps](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#creating-a-personal-access-token).

Then run the following R command, replacing the `auth_token` argument with
your own token:

```r
remotes::install_gitlab(
  repo = "ccao-data-science---modeling/packages/assessR",
  auth_token = "<your-personal-access-token>"
)
```

Once it is installed, you can use it just like any other package. Simply
call `library(assessR)` at the beginning of your script.

