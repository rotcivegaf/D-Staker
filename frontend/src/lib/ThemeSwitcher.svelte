<script type="ts">
  import {toggleTheme, theme, Theme} from "$store/theme";

  $: inDarkMode = $theme === Theme.DARK;
</script>

<input type="checkbox" class="toggle" on:click={toggleTheme} checked={inDarkMode} />