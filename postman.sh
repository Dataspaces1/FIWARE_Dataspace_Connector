#!/bin/bash
# Base URLs
KEYCLOAK_URL="http://keycloak-consumer.127.0.0.1.nip.io:8080"

# Variables
USERNAME="test-user"
PASSWORD="test"
CLIENT_ID="admin-cli"
CREDENTIAL_ID="user-credential"

# 1. Get Access Token
echo "Fetching Access Token..."
ACCESS_TOKEN=$(curl -s -X POST "${KEYCLOAK_URL}/realms/test-realm/protocol/openid-connect/token" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data "grant_type=password" \
  --data "client_id=${CLIENT_ID}" \
  --data "username=${USERNAME}" \
  --data "password=${PASSWORD}" | jq -r '.access_token')

if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "Error: Failed to fetch Access Token"
  exit 1
fi
echo "Access Token: $ACCESS_TOKEN"

# 2. Retrieve Credential Offer URI
echo "Fetching Credential Offer URI..."
OFFER_URI=$(curl -s -X GET "${KEYCLOAK_URL}/realms/test-realm/protocol/oid4vc/credential-offer-uri?credential_configuration_id=${CREDENTIAL_ID}" \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" | jq -r '"\(.issuer)\(.nonce)"')

if [[ -z "$OFFER_URI" ]]; then
  echo "Error: Failed to fetch Offer URI"
  exit 1
fi
echo "Offer URI: $OFFER_URI"

# 3. Retrieve Pre-authorized Code
echo "Fetching Pre-authorized Code..."
PRE_AUTHORIZED_CODE=$(curl -s -X GET "${OFFER_URI}" \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" | jq -r '.grants."urn:ietf:params:oauth:grant-type:pre-authorized_code"."pre-authorized_code"')

if [[ -z "$PRE_AUTHORIZED_CODE" ]]; then
  echo "Error: Failed to fetch Pre-authorized Code"
  exit 1
fi
echo "Pre-authorized Code: $PRE_AUTHORIZED_CODE"

# 4. Exchange the pre-authorized Code for credential access token
echo "Exchanging Pre-authorized Code for Credential Access Token..."
CREDENTIAL_ACCESS_TOKEN=$(curl -s -X POST "${KEYCLOAK_URL}/realms/test-realm/protocol/openid-connect/token" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data "grant_type=urn:ietf:params:oauth:grant-type:pre-authorized_code" \
  --data "pre-authorized_code=${PRE_AUTHORIZED_CODE}" | jq -r '.access_token')

if [[ -z "$CREDENTIAL_ACCESS_TOKEN" ]]; then
  echo "Error: Failed to fetch Credential Access Token"
  exit 1
fi
echo "Credential Access Token: $CREDENTIAL_ACCESS_TOKEN"

# 5. Fetch Verifiable Credential
echo "Fetching Verifiable Credential..."
VERIFIABLE_CREDENTIAL=$(curl -s -X POST "${KEYCLOAK_URL}/realms/test-realm/protocol/oid4vc/credential" \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${CREDENTIAL_ACCESS_TOKEN}" \
  --data "{\"credential_identifier\":\"${CREDENTIAL_ID}\", \"format\":\"jwt_vc\"}" | jq -r '.credential')

if [[ -z "$VERIFIABLE_CREDENTIAL" ]]; then
  echo "Error: Failed to fetch Verifiable Credential"
  exit 1
fi
echo "Verifiable Credential: $VERIFIABLE_CREDENTIAL"

