import js from "@eslint/js";
import globals from "globals";

export default [
    js.configs.recommended,
    {
        files: [
            "**/*.js",
            "**/*.ts",
            "**/*.cjs",
            "**/*.mjs",
        ],
        languageOptions: {
            sourceType: "module",
            ecmaVersion: 2024,
            globals: {
                ...globals.node,
                ...globals.es2021,
                ...globals.browser,
            }
        },
        rules: {
            "semi": ["error", "always"],
            "indent": ["error", 4],
            "quotes": ["error", "double"],
            "linebreak-style": ["error", "unix"],
            "no-unused-vars": ["error" , {
                "argsIgnorePattern": "^_",
                "varsIgnorePattern": "^_",
                "caughtErrorsIgnorePattern": "^_",
            }],
        }
    },
];
