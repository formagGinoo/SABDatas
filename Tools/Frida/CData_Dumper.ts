declare function send(message: any): void;
declare const Interceptor: any;
declare const console: { log: (...args: any[]) => void };
import "frida-il2cpp-bridge";

function stripAnsi(str: string): string {
    return str.replace(/\x1b\[[0-9;]*m/g, "");
}

console.log = function (...args: any[]) {
    const raw = args.join(" ");
    const clean = stripAnsi(raw);
    send("[CData Dumper] " + clean);
};

Il2Cpp.perform(() => {
    const assembly = Il2Cpp.domain.assembly("Scripts.Common");
    console.log(`Found assembly: ${assembly.name}`);
    
    // Mappa per associare le classi CData alle loro classi Element
    const cdataElementMap = new Map<string, any>();
    const savedClasses = new Set<string>();
    
    // Trova tutte le classi Element e mappale alle loro classi CData corrispondenti
    const allClasses = assembly.image.classes;
    
    let elementClassCount = 0;
    let cdataClassCount = 0;
    
    allClasses.forEach(klass => {
        if(klass.name.endsWith("_Element")) {
            elementClassCount++;
            const baseName = klass.name.replace("_Element", "");
            cdataElementMap.set(baseName, klass);
        }
        if(klass.name.startsWith("CData_") && !klass.name.endsWith("Element")) {
            cdataClassCount++;
        }
    });
    
    console.log(`Found ${elementClassCount} Element classes and ${cdataClassCount} CData classes`);
    
    function safeConvertValue(value: any, fieldName: string, fieldType: string): any {
        try {
            if (!value || value.isNull?.()) {
                return null;
            }
            
            if (fieldType.includes("[]")) {
                try {
                    const stringValue = value.toString();
                    if (stringValue && stringValue !== "[object Object]") {
                        return stringValue;
                    }
                    
                    if (value.length !== undefined) {
                        return `Array[${value.length}]`;
                    }
                    
                    return "Array (unable to parse)";
                } catch (e) {
                    return `Array processing error: ${e}`;
                }
            }
            
            try {
                return value.toString();
            } catch (e) {
                return `Error: ${e}`;
            }
            
        } catch (e) {
            return `Error: ${e}`;
        }
    }

    function parseElementToObject(elementInstance: any, elementClass: any): any {
        const result: any = {};
        
        try {
            if (elementInstance.class.name.includes("Dictionary")) {
                return {
                    _error: `Wrong object type: got ${elementInstance.class.name}, expected ${elementClass.name}`
                };
            }
            
            const fields = elementClass.fields;
            
            fields.forEach((field: any) => {
                try {
                    if(!field.isStatic) {
                        const fieldValue = elementInstance.field(field.name).value;
                        result[field.name] = safeConvertValue(fieldValue, field.name, field.type.name);
                    }
                } catch(fieldError) {
                    result[field.name] = `Error: ${fieldError}`;
                    console.log(`Error reading field ${field.name}: ${fieldError}`);
                }
            });
        } catch(e) {
            result._error = `Error parsing fields: ${e}`;
            console.log(`General error parsing ${elementClass.name}: ${e}`);
        }
        
        return result;
    }
    
    function saveDictionaryToJson(dictionary: any, className: string, elementClass: any, force: boolean = false): void {
        // Evita duplicati a meno che non sia forzato
        if (!force && savedClasses.has(className)) {
            return;
        }
        
        if(!dictionary || dictionary.isNull()) {
            return;
        }
        
        const data: any = {
            className: className,
            timestamp: new Date().toISOString(),
            data: {}
        };
        
        try {
            const count = dictionary.method("get_Count").invoke();
            
            if(count === 0) {
                data.status = "empty_count_zero";
                return;
            } else {
                const keys = dictionary.method("get_Keys").invoke();
                
                if(keys && !keys.isNull()) {
                    const keysEnumerator = keys.method("GetEnumerator").invoke();
                    let processedCount = 0;
                    
                    while(keysEnumerator.method("MoveNext").invoke()) {
                        try {
                            const key = keysEnumerator.method("get_Current").invoke();
                            const value = dictionary.method("get_Item").invoke(key);
                            
                            if(value && !value.isNull()) {
                                const valueClassName = value.class.name;
                                
                                if(valueClassName.includes("_Element")) {
                                    // È un elemento Element normale
                                    if(elementClass) {
                                        data.data[key.toString()] = parseElementToObject(value, elementClass);
                                    } else {
                                        data.data[key.toString()] = {
                                            type: valueClassName,
                                            value: safeConvertValue(value, "value", "object")
                                        };
                                    }
                                } else if(valueClassName.includes("Dictionary")) {
                                    // dictionary annidato
                                    //console.log(`[${className}] Found nested Dictionary for key ${key}`);
                                    
                                    try {
                                        const nestedCount = value.method("get_Count").invoke();
                                        let nestedProcessed = 0;
                                        const nestedData: any = {};
                                        
                                        if(nestedCount > 0 && nestedCount <= 100) {
                                            const nestedKeys = value.method("get_Keys").invoke();
                                            
                                            if(nestedKeys && !nestedKeys.isNull()) {
                                                const nestedKeysEnum = nestedKeys.method("GetEnumerator").invoke();
                                                
                                                while(nestedKeysEnum.method("MoveNext").invoke() && nestedProcessed < 50) {
                                                    try {
                                                        const nestedKey = nestedKeysEnum.method("get_Current").invoke();
                                                        const nestedValue = value.method("get_Item").invoke(nestedKey);
                                                        
                                                        if(nestedValue && !nestedValue.isNull()) {
                                                            if(nestedValue.class.name.includes("_Element") && elementClass) {
                                                                nestedData[nestedKey.toString()] = parseElementToObject(nestedValue, elementClass);
                                                            } else {
                                                                nestedData[nestedKey.toString()] = {
                                                                    type: nestedValue.class.name,
                                                                    value: safeConvertValue(nestedValue, "nestedValue", "object")
                                                                };
                                                            }
                                                        } else {
                                                            nestedData[nestedKey.toString()] = null;
                                                        }
                                                        nestedProcessed++;
                                                    } catch(nestedError) {
                                                        console.log(`[${className}] Error processing nested item ${nestedProcessed}: ${nestedError}`);
                                                        nestedProcessed++;
                                                    }
                                                }
                                            }
                                            
                                            data.data[key.toString()] = {
                                                _type: "nested_dictionary",
                                                _count: nestedCount,
                                                _processed: nestedProcessed,
                                                data: nestedData
                                            };
                                        } else {
                                            // dictionary troppo grande o vuoto
                                            data.data[key.toString()] = {
                                                _skipped: `Nested Dictionary (${nestedCount} items - ${nestedCount === 0 ? 'empty' : 'too large'})`,
                                                _type: valueClassName,
                                                _count: nestedCount
                                            };
                                        }
                                    } catch(nestedDictError) {
                                        console.log(`[${className}] Error processing nested Dictionary: ${nestedDictError}`);
                                        data.data[key.toString()] = {
                                            _skipped: "Nested Dictionary (processing error)",
                                            _type: valueClassName,
                                            //@ts-ignore
                                            _error: nestedDictError.toString()
                                        };
                                    }
                                } else {
                                    // Tipo sconosciuto
                                    data.data[key.toString()] = {
                                        _type: valueClassName,
                                        _value: safeConvertValue(value, "unknown", "object")
                                    };
                                }
                            } else {
                                data.data[key.toString()] = null;
                            }
                            
                            processedCount++;
                            
                            
                        } catch(itemError) {
                            console.log(`[${className}] Error processing item ${processedCount}: ${itemError}`);
                            data.data[processedCount.toString()] = {
                                _error: `Processing error: ${itemError}`
                            };
                            processedCount++;
                        }
                    }
                    
                    data.status = `processed_${processedCount}_items`;
                    
                    // Salva solo se ha dati significativi
                    if (processedCount > 0) {
                        savedClasses.add(className);
                        
                        const jsonString = JSON.stringify(data, null, 2);
                        send({
                            type: "save_json",
                            className: className,
                            data: jsonString
                        });
                        
                        console.log(`[${className}] Saved with ${processedCount} items`);
                    }
                }
            }
            
        } catch(e) {
            console.log(`[${className}] Error creating JSON: ${e}`);
        }
    }
    
    // Hook di TUTTI i metodi _addItem per TUTTE le classi CData
    function hookAllAddItemMethods(): void {
        const cdataClasses = assembly.image.classes.filter(klass => 
            klass.name.startsWith("CData_") && !klass.name.endsWith("Element")
        );
        
        //console.log(`Hooking _addItem methods for ${cdataClasses.length} CData classes`);
        
        cdataClasses.forEach(klass => {
            try {
                // Trova tutti i metodi _addItem per questa classe
                const addItemMethods = klass.methods.filter((m: any) => m.name === "_addItem");
                
                if (addItemMethods.length > 0) {
                    //console.log(`[${klass.name}] Found ${addItemMethods.length} _addItem overload(s)`);
                    
                    addItemMethods.forEach((method: any, index: number) => {
                        try {
                            const paramCount = method.parameterCount;
                            //console.log(`[${klass.name}] Overload ${index + 1}: ${paramCount} parameters`);
                            
                            // Salva il riferimento all'implementazione originale
                            const originalImplementation = method.implementation;
                            
                            method.implementation = function(...args: any[]) {
                                //console.log(`[${klass.name}] _addItem(${paramCount} params) called with ${args.length} args`);
                                
                                // Chiama l'implementazione originale CORRETTAMENTE
                                let result;
                                try {
                                    //usa originalImplementation.call(this, ...args)
                                    if (originalImplementation) {
                                        result = originalImplementation.call(this, ...args);
                                    } else {
                                        // Fallback: usa this.method invece di method.invoke
                                        if (paramCount === 2) {
                                            result = this.method("_addItem").invoke(args[0], args[1]);
                                        } else if (paramCount === 3) {
                                            result = this.method("_addItem").invoke(args[0], args[1], args[2]);
                                        } else {
                                            result = this.method("_addItem").invoke(...args);
                                        }
                                    }
                                } catch(invokeError) {
                                    console.log(`[${klass.name}] Error calling _addItem overload ${index + 1}: ${invokeError}`);
                                    return;
                                }
                                
                                // salva il dictionary dopo ogni aggiunta SOLO se l'operazione è riuscita
                                if (result) {
                                    setTimeout(() => {
                                        try {
                                            const dictionary = this.method("GetAll").invoke();
                                            if(dictionary && !dictionary.isNull()) {
                                                const count = dictionary.method("get_Count").invoke();
                                                
                                                // salva in base al tipo di classe
                                                if (klass.name.includes("Language") || klass.name.includes("Lang")) {
                                                    // per le classi di linguaggio, salva ogni 50 elementi
                                                    if (count > 0 && count % 50 === 0) {
                                                        //console.log(`[${klass.name}] Auto-saving at ${count} items`);
                                                        const elementClass = cdataElementMap.get(klass.name);
                                                        saveDictionaryToJson(dictionary, klass.name, elementClass);
                                                    }
                                                } else {
                                                    // per altre classi, salva ogni 5 elementi per debug
                                                    if (count > 0 && count % 5 === 0) {
                                                        const elementClass = cdataElementMap.get(klass.name);
                                                        saveDictionaryToJson(dictionary, klass.name, elementClass);
                                                    }
                                                }
                                            }
                                        } catch(dictError) {
                                            console.log(`[${klass.name}] Error checking dictionary: ${dictError}`);
                                        }
                                    }, 100);
                                }
                                
                                return result;
                            };
                            
                            //console.log(`[${klass.name}] Hooked _addItem overload ${index + 1} (${paramCount} params)`);
                        } catch(hookError) {
                            console.log(`[${klass.name}] Failed to hook _addItem overload ${index + 1}: ${hookError}`);
                        }
                    });
                }
            } catch(classError) {
                console.log(` [${klass.name}] Error processing _addItem methods: ${classError}`);
            }
        });
    }
    
    // Versione polling semplificata
    function startPeriodicDump(): void {
        const cdataClasses = assembly.image.classes.filter(klass => 
            klass.name.startsWith("CData_") && !klass.name.endsWith("Element")
        );
        
        console.log(`Starting periodic dump for ${cdataClasses.length} classes`);
        
        // Controlla ogni 15 secondi
        setInterval(() => {
            cdataClasses.forEach(klass => {
                try {
                    const instance = klass.method("GetInstance").invoke();
                    //@ts-ignore
                    if(instance && !instance.isNull()) {
                        //@ts-ignore
                        const dictionary = instance.method("GetAll").invoke();
                        if(dictionary && !dictionary.isNull()) {
                            const count = dictionary.method("get_Count").invoke();
                            
                            if(count > 0) {
                                const elementClass = cdataElementMap.get(klass.name);
                                saveDictionaryToJson(dictionary, klass.name, elementClass);
                            }
                        }
                    }
                } catch(e) {
                }
            });
        }, 15000); // Ogni 15 secondi
    }
    
    // Salvataggio finale forzato
    function forceFinalDump(): void {
        const cdataClasses = assembly.image.classes.filter(klass => 
            klass.name.startsWith("CData_") && !klass.name.endsWith("Element")
        );
        
        console.log(`Final dump of all available data...`);
        
        cdataClasses.forEach(klass => {
            try {
                const instance = klass.method("GetInstance").invoke();
                //@ts-ignore
                if(instance && !instance.isNull()) {
                    //@ts-ignore
                    const dictionary = instance.method("GetAll").invoke();
                    if(dictionary && !dictionary.isNull()) {
                        const count = dictionary.method("get_Count").invoke();
                        
                        if(count > 0) {
                            const elementClass = cdataElementMap.get(klass.name);
                            saveDictionaryToJson(dictionary, klass.name, elementClass, true); // Force save
                        }
                    }
                }
            } catch(e) {
            }
        });
    }
    
    // Avvia tutto
    setTimeout(() => {
        console.log(`Starting CData dump process...`);
        hookAllAddItemMethods();
        startPeriodicDump();
        
        // Salvataggio finale dopo 2 minuti
        setTimeout(() => {
            forceFinalDump();
        }, 120000); // 2 minuti
        
    }, 3000);
});