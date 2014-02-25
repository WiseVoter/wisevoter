# Style Guide
License: CC-BY-SA Attribution

This is document summarizes CSS styles for WiseVoter website using smacss using [kss](https://github.com/kneath/kss) similar to [github](https://github.com/styleguide)

Global nice to have document (perhaps a section for each)

   	* Base: Framework, reset etc.
   	* Layout: Global layout and media query behavior.
   	* Colors & Themes: All colors in the style, pick a scheme.
   	* Fonts: Fonts used
   	* Modules: [Email]
   	* Behaviors & Events: Javascript based? Use [TomDoc](http://tomdoc.org/), good example is [github](https://github.com/styleguide/javascript/2.0). Document as js-* css classes as behaviors

Goals

	* Be able to add seasonal themes (close to election, election day)
	* Be able to experiment with typography, 

Tips

	* For colors & themes
	  ** kuler, colorschemedesigner.com, clrs.cc, subtle patterns.
	* For CSS elements
	  ** check browser [compatibility](http://caniuse.com/)

## Base
Framework, reset, print, global elements (site wide html elements, id as applicable)

## Layout
Marketing, Two-page, three-page, media-queries
### Responsive

## Colors & Themes
Site wide colors and themes.
### Typography
Fonts used (prefer sans-serif)

## Modules or Components
Rules

	* All modules should work independent of layout but with base, and one theme.
	* Each component should be able to work only with css class elements
	* Naming convention [behavior]-[component]-

### Header
### Site-Nav
### Page (types) [marketing, politician, issues, articles, ]
### Page Nav
### Footer

## Behaviors & Events
Mark JS specific class as js- as it makes sense.
