import resolve from 'rollup-plugin-node-resolve';
import svelte from 'rollup-plugin-svelte';
import commonjs from 'rollup-plugin-commonjs';
import css from 'rollup-plugin-css-only'

const onwarn = warning => {
  if (warning.code === 'CIRCULAR_DEPENDENCY' && /moment/.test(warning.importer)) {
    return
  }
  console.warn(`(!) ${warning.message}`)
}

module.exports = {
    input: ['js/app.js', 'js/index.js'],
    output: {
      dir: '../priv/static/js',
      sourcemap: true,
      format: 'es'
    },
  onwarn,
  plugins: [
    resolve({
      mainFields: ['module', 'main']
    }),
    svelte({
      css:  function(css){
        css.write('../priv/static/css/svelte.css')
      }
    }),
    resolve({
      mainFields: ['module', 'main']
    }),
    css({output: '../priv/static/css/app.css'}),
    commonjs({
      // search for files other than .js files (must already
      // be transpiled by a previous plugin!)
      extensions: [ '.js', '.html' ],  // Default: [ '.js' ]
    })
  ]
};
