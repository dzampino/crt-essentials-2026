learndmarc-1
DMARC fails, the message will NOT be treated as suspicious
- Domain part red.secondary.com from the RFC5321.MailFrom address (MAIL FROM:) is used to retrieve the SPF policy
- Domain part blue.secondary.com from the RFC5322.From address (From:) is used to check DMARC alignment
- The message is signed with a DKIM signature and passed validation
- SPF failed because source IP address 153.112.107.49 is NOT allowed to send on behalf of red.secondary.com
- Having "t=y" in a DMARC policy signals that the Domain Owner is in test mode and requests that mail receivers not apply the stated handling policies (p, sp, or np) to messages that fail validation checks
- The DMARC alignment policy is 'relaxed'. This is because the 'aspf' and 'adkim' elements were not specified or had an 'r' value. This means that only the organizational domains have to be in alignment
- DKIM passed validation but there is NO alignment (primary.com != secondary.com)
- DMARC failed because neither SPF or DKIM passed validation and have alignment

learndmarc-2
DMARC fails, the message will be quarantined
- Domain part red.primary.com from the RFC5321.MailFrom address (MAIL FROM:) is used to retrieve the SPF policy
- Domain part blue.primary.com from the RFC5322.From address (From:) is used to check DMARC alignment
- The message is signed with a DKIM signature but failed validation (auth result 'fail'), the message has been altered
- SPF failed because source IP address 97.196.174.88 is NOT allowed to send on behalf of red.primary.com
- The DMARC alignment policy is 'strict'. The 'aspf' and 'adkim' elements have an 's' value. This means that both domain and subdomain need to be an exact match
- DMARC failed because neither SPF or DKIM passed validation and have alignment
- DMARC failed and the policy is set to 'quarantine' so the requested action is to quarantine the message

learndmarc-3
DMARC fails, the message will NOT be treated as suspicious
- Domain part blue.secondary.com from the RFC5321.MailFrom address (MAIL FROM:) is used to retrieve the SPF policy
- Domain part red.primary.com from the RFC5322.From address (From:) is used to check DMARC alignment
- The message is signed with a DKIM signature and passed validation
- SPF failed because source IP address 156.157.23.197 is NOT allowed to send on behalf of blue.secondary.com
- The DMARC alignment policy is 'strict'. The 'aspf' and 'adkim' elements have an 's' value. This means that both domain and subdomain need to be an exact match
- DKIM passed validation but there is NO alignment (blue.primary.com != red.primary.com)
- DMARC failed because neither SPF or DKIM passed validation and have alignment
- DMARC failed but the policy is set to 'none' so no action will be taken

