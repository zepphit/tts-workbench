<!-- vendored from https://api.tabletopsimulator.com/behavior/clock/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Clock

The Clock behavior is present on the Digital Clock object.

## Clock Modes

- **Current Time**: Displays the current time of the host.

- **Stopwatch**: Displays a running count up.

- **Timer**: Displays a countdown and beeps once complete.

## Member Variables

| Variable | Type | Description |
| --- | --- | --- |
| paused | *bool* | If the clock timer is paused. |

---

## Function Summary

######

######

######

######

| Function Name | Return | Description |
| --- | --- | --- |
| getValue()getValue() | *returns int* | Current time in stopwatch or timer mode. Clock mode returns 0. This function acts the same as [Object's getValue()](object.md#getvalue). |
| pauseStart()pauseStart() | *returns bool* | Pauses/resumes a Clock in stopwatch or timer mode. |
| setValue(*int* seconds) | *returns bool* | Switches clock to timer and sets countdown time. This function acts the same as [Object's setValue()](object.md#setvalue). |
| showCurrentTime()showCurrentTime() | *returns bool* | Switches clock to display current time. It will clear any stopwatch or timer. |
| startStopwatch()startStopwatch() | *returns bool* | Switches clock to stopwatch, setting time to 0. It will reset time if already in stopwatch mode. |

---

## Function Details

### setValue(...)

*returns bool*  Set the timer to display a number of seconds. This function acts the same as [Object's setValue()](object.md#setvalue). If the Clock is not in timer mode, it will be switched. If it is in timer mode, it will be paused and the remaining time will be changed. This will not start the countdown on its own.

> **setValue(seconds)**
>
> - *int* **seconds**: How many seconds will be counted down.

```
self.Clock.setValue(30)
```
