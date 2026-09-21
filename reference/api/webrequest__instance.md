<!-- vendored from https://api.tabletopsimulator.com/webrequest/instance/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Web Request Instance

Web request instances represent a singular in-progress, completed or failed web request. They are created via the [Web Request Manager](webrequest__manager.md).

## Member Variables

| Variable | Description | Type |
| --- | --- | --- |
| download_progress | Download percentage, represented as a number in the range 0-1. | *float* |
| error | Reason why the request failed to complete.If the server responds with a [HTTP status code](#response_code) that represents a HTTP error (4xx/5xx), this is *not* considered a request error. | *string* |
| is_error | If the request failed due to an [error](#error). | *bool* |
| is_done | If the request completed *or failed*. If the request failed, [is_error](#is_error) will be set. | *bool* |
| response_code | Response [HTTP status code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status). | *number* |
| text | Response body. | *string* |
| upload_progress | Upload percentage, represented as a number from 0-1. | *float* |
| url | The request's target URL. If the request was redirected, this will still return the initial URL. | *string* |

## Functions

######

######

######

| Function Name | Return | Description |
| --- | --- | --- |
| dispose()dispose() |  | **Web requests are automatically disposed of after a request completes/fails.**You may call this method to *try* abort a request and dispose of it early. |
| getResponseHeader(getResponseHeader(...)*string* name) | *returns string* | Returns the value of the specified response header, or `nil` if no such header exists. |
| getResponseHeaders()getResponseHeaders() | *returns table* | Returns the table of response headers. Keys and values are both *string* . |
