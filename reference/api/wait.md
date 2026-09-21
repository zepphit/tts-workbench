<!-- vendored from https://api.tabletopsimulator.com/wait/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Wait

The `Wait` class is a static global class which allows you to schedule code (functions) to be executed later on.

> **Important**
>
> Please note that `Wait` does *not* pause Lua script execution, *because that would freeze Tabletop Simulator!* The next line of code after a `Wait` function call will always be executed immediately.

## Function Summary

| Function Name | Description | Return |
| --- | --- | --- |
| collect(*table* expected_ids, *func* on_finished, *func* on_add, *func* on_error) | Tracks progress of a given task for multiple entities (typically players). | *returns table* |
| condition(*func* toRunFunc, *func* conditionFunc, *float* timeout, *func* timeoutFunc) | Schedules a function to be executed after the specified condition has been met. | *returns int* |
| frames(*func* toRunFunc, *int* numberFrames) | Schedules a function to be executed after the specified number of frames have elapsed. | *returns int* |
| stop(*int* id) | Cancels a Wait-scheduled function. | *returns bool* |
| stopAll() | Cancels all Wait-scheduled functions. |  |
| time(*func* toRunFunc, *float* seconds, *int* repetitions) | Schedules a function to be executed after the specified amount of time (in seconds) has elapsed. | *returns int* |

---

## Function Details

### collect(...)

*returns table*  Creates a `collect_table` that can be used to track the progress across a specific task for multiple entities (typically players).

> **collect(expected_ids, on_finished, on_add, on_error)**
>
> - *table* **expected_ids**: A list of IDs which the `collect_table` will wait for. These can be anything as long as each is unique and can be used as a table key; player colors would be the typical use if you want to do a thing for each player.
>
> - *func* **on_finished**: The function that will be executed once every ID has been added.
>
> - *func* **on_add**: A function that will be executed whenever you call `collect_table:add` for an ID.
>
>   - Optional
>
> - *func* **on_error**: A function that will be executed whenever an error occurs (trying to add an unexpected ID, or the same ID more than once).
>
>   - Optional

Call this to get your `collect_table`. You may then call `collect_table:add(id, ...)` for each expected ID. When you call it these will happen:

- `collect_table.results[id]` is set to whatever `...` you passed in.

- If you provided an `on_add`, it is called as `on_add(id, ...)`.

If you provided an `on_error` function it will be called if either of these siutations occurs:

- If you call `collect_table:add` **more than once** for the same id, it will be called with `on_error(Wait.COLLECT_DUPLICATE, id, ...)`.

- If you call `collect_table:add` with an ID that **you did not list in your expected ids**, it will be called with `on_error(Wait.COLLECT_UNKNOWN, id, ...)`.

Once `collect_table:add` has been called for every expected ID, `on_finished` will be called with `on_finished(collect_table.results)`.

You may call `collect_table:reset()` to reset the collect_table, allowing you to reuse it.

> **Example**
>
> Use `Wait.collect` and `chooseInHand` to draft cards.

```lua
function startDraft()
    -- Each player picks 1 to 3 cards in their hand, which will immediately be moved to their
    -- stash.
    -- Once all players have picked, the cards they didn't choose are given to the next
    -- player, the cards they picked are returned to their hand.
    local players = chooseInHand("my_draft", 1, 3, "{en}Pick up to 3 cards!")
    draft_collect = Wait.collect(players,
        function(results)  -- on_finished
            local send_to = {}
            local chosen_cards = {}
            for player, chosen in pairs(results) do
                for i, card in ipairs(chosen) do
                    chosen_cards[card.guid] = true
                end
            end
            for player, chosen in pairs(results) do
                local send_to_player = next_player(players, player)
                local cards_in_hand = Player[player].getHandObjects()
                for i, card in ipairs(cards_in_hand) do
                    if not chosen_cards[card.guid] then
                        getObjectFromGUID(card.guid).sendToHand(send_to_player)
                    end
                end
                Player[player].drawHandStash()
            end
        end
        ,
        function(...)  -- on_add
            for i, card in ipairs(...) do
                card.moveToHandStash()
            end
        end
        ,
        function(player_color, error, ...)  -- on_error
            log({"ERR", error, player_color, ...})
        end
    )
end

function onPlayerHandChoice(player_color, label, objects)
    if label == "my_draft" then
        draft_collect:add(player_color, objects)
    end
end

function next_player(players, current_player)
    local return_next_player = false
    for i, player in ipairs(players) do
        if return_next_player then
            return player
        elseif player == current_player then
            return_next_player = true
        end
    end
    return players[1]
end
```

---

### condition(...)

*returns int*  Schedules a function to be executed after the specified condition has been met.

The return value is a unique ID that may be used to [stop](#stop) the scheduled function before it runs.

> **condition(toRunFunc, conditionFunc, timeout, timeoutFunc)**
>
> - *func* **toRunFunc**: The function to be executed after the specified condition is met.
>
> - *func* **conditionFunc**: The function that will be executed repeatedly, until it returns `true` (or the `timeout` is reached).
>
> - *float* **timeout**: The amount of time (in seconds) that may elapse before the scheduled function is cancelled.
>
>   - Optional, defaults to never timing out.
>
> - *func* **timeoutFunc**: The function that will be executed if the timeout is reached.
>
>   - Optional

`conditionFunc` will be executed (possibly several times) until it returns `true`, at which point the scheduled function (`toRunFunc`) will be executed, and `conditionFunc` will no longer be executed again.

Optionally, a `timeout` and `timeoutFunc` may be specified. If `conditionFunc` does not return `true` before the specified timeout (seconds) has elapsed, then the scheduled function is cancelled i.e. will not be called. If a `timeoutFunc` is provided, then it will be called when the timeout is reached.

> **Example**
>
> Roll a die, and wait until it comes to rest.

```lua
die.randomize() -- Roll a die
Wait.condition(
    function() -- Executed after our condition is met
        if die.isDestroyed() then
            print("Die was destroyed before it came to rest.")
        else
            print(die.getRotationValue() .. " was rolled.")
        end
    end,
    function() -- Condition function
        return die.isDestroyed() or die.resting
    end
)
```

> **Example**
>
> Launch an object into the air with a random impulse and wait until it comes to rest. However, if it's taking too long (more than two seconds), give up waiting.

```lua
local upwardImpulse = math.random(5, 25)
object.addForce({0, upwardImpulse, 0})
Wait.condition(
    function()
        if object.isDestroyed() then
            print("Object was destroyed before it came to rest.")
        else
            print("The object came to rest in under two seconds.")
        end
    end,
    function()
        return object.isDestroyed() or object.resting
    end,
    2, -- second timeout
    function() -- Executed if our timeout is reached
        print("Took too long to come to rest.")
    end
)
```

---

### frames(...)

*returns int*  Schedules a function to be executed after the specified number of frames have elapsed.

The return value is a unique ID that may be used to [stop](#stop) the scheduled function before it runs.

> **frames(toRunFunc, frameCount)**
>
> - *func* **toRunFunc**: The function to be executed after the specified number of frames have elapsed.
>
> - *int* **numberFrames**: The number of frames that must elapse before `toRunFunc` is executed.
>
>   - Optional, defaults to `1`.
>
> **Example**
>
> Prints "Hello!" after 60 frames have elapsed.

```lua
Wait.frames(
    function()
        print("Hello!")
    end,
    60
)
```

It's a matter of personal preference, but it's quite common to see the above compacted into one line, like:

```lua
Wait.frames(function() print("Hello!") end, 60)
```

> **Advanced Example**
>
> Prints "1", "2", "3", "4", "5", waiting 60 frames before each printed number.
>
> Note that the scheduled function, upon execution, will reschedule itself unless `count` has reached 5.

```lua
local count = 1
local function printAndReschedule()
    print(count)

    if count < 5 then
        count = count + 1
        Wait.frames(printAndReschedule, 60)
    end
end

Wait.frames(printAndReschedule, 60)
```

---

### stop(...)

*returns bool*  Cancels a Wait-scheduled function.

> **stop(id)**
>
> - *int* **id**: A wait ID (returned from `Wait` scheduling functions).
>
> **Example**
>
> Schedules two functions: one that says "Hello!", and one that says "Goodbye!". However, the latter is stopped before it has a chance to execute i.e. We'll see "Hello!" printed, but we *won't* see "Goodbye!"

```lua
Wait.time(function() print("Hello!") end, 1)
local goodbyeId = Wait.time(function() print("Goodbye!") end, 2)
Wait.stop(goodbyeId)
```

---

### stopAll(...)

Cancels all Wait-scheduled functions.

> **Warning**
>
> You should be extremely careful using this function. Generally you should cancel individual scheduled functions with [stop](#stop) instead.
>
> **Example**
>
> Schedules two functions: one that says "Hello!", and one that says "Goodbye!". However, *both* are stopped before either has the chance to execute.

```lua
Wait.time(function() print("Hello!") end, 1)
Wait.time(function() print("Goodbye!") end, 2)
Wait.stopAll()
```

---

### time(...)

*returns int*  Schedules a function to be executed after the specified amount of time (in seconds) has elapsed.

The return value is a unique ID that may be used to [stop](#stop) the scheduled function before it runs.

> **time(toRunFunc, seconds, repetitions)**
>
> - *func* **toRunFunc**: The function to be executed after the specified amount of time has elapsed.
>
> - *float* **seconds**: The amount of time that must elapse before `toRunFunc` is executed.
>
> - *int* **repetitions**: Number of times `toRunFunc` will be (re)scheduled. `-1` is infinite repetitions.
>
>   - Optional, defaults to `1`.

`repetitions` is optional and defaults to `1`. When `repetitions` is a positive number, `toRunFunc` will execute for the specified number of repetitions, with the specified time delay before and between each execution. When `repetitions` is `-1`, `toRunFunc` will be re-scheduled indefinitely (i.e. infinite repetitions).

> **Example**
>
> Prints "Hello!" after 1 second has elapsed.

```lua
Wait.time(
    function()
        print("Hello!")
    end,
    1
)
```

It's a matter of personal preference, but it's quite common to see the above compacted into one line, like:

```lua
Wait.time(function() print("Hello!") end, 1)
```

> **Example**
>
> Prints "1", "2", "3", "4", "5", waiting 1 second before each printed number.

```lua
local count = 1
Wait.time(
    function()
        print(count)
        count = count + 1
    end,
    1, -- second delay
    5 -- repetitions
)
```

---
