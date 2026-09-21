<!-- vendored from https://api.tabletopsimulator.com/behavior/assetbundle/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# AssetBundle

The AssetBundle behavior is present on Objects that were created from a [custom AssetBundle](https://kb.tabletopsimulator.com/custom-content/custom-assetbundle/).

## Function Summary

######

######

######

| Function Name | Description | Return |
| --- | --- | --- |
| getLoopingEffectIndex()getLoopingEffectIndex() | *returns int* | Index of the currently looping effect. Indexes starts at 0. |
| getLoopingEffects() | *returns table* | Returns a Table with the keys "index" and "name" for each looping effect. |
| getTriggerEffects() | *returns table* | Returns a Table with the keys "index" and "name" for each trigger effect. |
| playLoopingEffect(playLoopingEffect(...)*int* index) | *returns nil* | Starts playing a looping effect. Indexes starts at 0. |
| playTriggerEffect(playTriggerEffect(...)*int* index) | *returns nil* | Starts playing a trigger effect. Indexes starts at 0. |

---

## Function Details

### getLoopingEffects()

*returns table*  Returns a Table with the keys "index" and "name" for each looping effect.

```
    -- Example usage
    effectTable = self.AssetBundle.getLoopingEffects()
```

```
    -- Example returned table
    {
        {index=0, name="Effect Name 1"},
        {index=1, name="Effect Name 2"},
    }
```

---

### getTriggerEffects()

*returns table*  Returns a Table with the keys "index" and "name" for each trigger effect.

```
    -- Example usage
    effectTable = self.AssetBundle.getTriggerEffects()
```

```
    -- Example returned table
    {
        {index=0, name="Effect Name 1"},
        {index=1, name="Effect Name 2"},
    }
```
