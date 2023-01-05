#!/usr/bin/env sh

# Pre-receive hook that will block commits with messges that do not follow regex rule

commit_msg_type_regex='feat|fix|perf'
commit_msg_scope_regex='XCP|MDS|SCO|ICDO|SAM|MFRP|NCP|OSD|FSD|PO|DSCAP|MDO|MIDO|AAD|AAB|APS|CYBER|GRPA|IPP|SEO|CON|DEP|EXLN|BLAZE|DCN|APD|GCORE|CTRN|ASO|PTRN|RAMERS|MES|WO|RDMTN|HSIA|HSM|S2|AS|HWS|TAGP|CMI|POP|SUP|LEIS|MGLV|DIS'
commit_ticket_regex='[0-9]{1,5}'
commit_msg_subject_regex='.{1,100}'
##commit_msg_regex="^(${commit_msg_type_regex})(\(${commit_msg_scope_regex}-[0-9]{1,5}))?:(${commit_msg_subject_regex})\$"
##commit_msg_regex="^(${commit_msg_type_regex})(\(${commit_msg_scope_regex})-[0-9]{1,5})\)?:(${commit_msg_subject_regex})\$"
commit_msg_regex="^(${commit_msg_type_regex})(\((${commit_msg_scope_regex})-(${commit_ticket_regex}))\)[!]?:(${commit_msg_subject_regex})\$"


merge_msg_regex="^Merge branch '.+'\$"

zero_commit="0000000000000000000000000000000000000000"

# Do not traverse over commits that are already in the repository
excludeExisting="--not --all"


error=""
while read oldrev newrev refname; do
  # branch or tag get deleted
  if [ "$newrev" = "$zero_commit" ]; then
    continue
  fi

  # Check for new branch or tag
  if [ "$oldrev" = "$zero_commit" ]; then
    rev_span=`git rev-list $newrev $excludeExisting`
  else
    rev_span=`git rev-list $oldrev..$newrev $excludeExisting`
  fi

  for commit in $rev_span; do
    commit_msg_header=$(git show -s --format=%s $commit)
    if ! [[ "$commit_msg_header" =~ (${commit_msg_regex})|(${merge_msg_regex}) ]]; then
      echo "$commit" >&2
      echo "ERROR: Invalid commit message format" >&2
      echo "$commit_msg_header" >&2
      error="true"
    fi
  done
done

if [ -n "$error" ]; then
  exit 1
fi
