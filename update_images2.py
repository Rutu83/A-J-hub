import os

def update_file(filepath):
    with open(filepath, 'r') as f:
        text = f.read()

    original_text = text

    def process_calls(text, call_name, prop_name, new_prop):
        idx = 0
        while True:
            start_idx = text.find(call_name + '(', idx)
            if start_idx == -1:
                break
            
            # Find the end of this call
            paren_count = 0
            in_string = False
            string_char = ''
            call_open_idx = start_idx + len(call_name)
            call_close_idx = -1
            
            for i in range(call_open_idx, len(text)):
                c = text[i]
                if not in_string and (c == '"' or c == "'"):
                    in_string = True
                    string_char = c
                elif in_string and c == string_char and text[i-1] != '\\':
                    in_string = False
                elif not in_string:
                    if c == '(':
                        paren_count += 1
                    elif c == ')':
                        paren_count -= 1
                        if paren_count == 0:
                            call_close_idx = i
                            break
            
            if call_close_idx == -1:
                idx = start_idx + len(call_name)
                continue
                
            # Now we have the bounds of the arguments: text[call_open_idx+1 : call_close_idx]
            args_text = text[call_open_idx+1 : call_close_idx]
            
            # Let's find prop_name inside args_text at level 0
            prop_idx = -1
            p_level = 0
            in_s = False
            s_c = ''
            
            # We will search for prop_name + ':' but only at p_level == 0
            # To be safe, we can just tokenize
            for i in range(len(args_text)):
                c = args_text[i]
                if not in_s and (c == '"' or c == "'"):
                    in_s = True
                    s_c = c
                elif in_s and c == s_c and args_text[i-1] != '\\':
                    in_s = False
                elif not in_s:
                    if c in '([{':
                        p_level += 1
                    elif c in ')]}':
                        p_level -= 1
                    elif p_level == 0:
                        # check if prop_name starts here
                        if args_text.startswith(prop_name, i):
                            # verify it's a whole word
                            if (i == 0 or not args_text[i-1].isalnum()) and not args_text[i+len(prop_name)].isalnum():
                                # verify it's followed by colon at level 0 before any other commas
                                # just check if the next non-whitespace is colon
                                next_chars = args_text[i+len(prop_name):].lstrip()
                                if next_chars.startswith(':'):
                                    prop_idx = i
                                    break
            
            if prop_idx != -1:
                # We found the existing property. We need to find where it ends.
                # It ends at the first comma at p_level == 0, or at the end of args_text
                prop_end_idx = -1
                p_level = 0
                in_s = False
                for i in range(prop_idx, len(args_text)):
                    c = args_text[i]
                    if not in_s and (c == '"' or c == "'"):
                        in_s = True
                        s_c = c
                    elif in_s and c == s_c and args_text[i-1] != '\\':
                        in_s = False
                    elif not in_s:
                        if c in '([{':
                            p_level += 1
                        elif c in ')]}':
                            p_level -= 1
                        elif p_level == 0 and c == ',':
                            prop_end_idx = i
                            break
                
                if prop_end_idx != -1:
                    # Remove the property entirely, including its comma
                    new_args_text = args_text[:prop_idx] + args_text[prop_end_idx+1:]
                else:
                    new_args_text = args_text[:prop_idx]
                    
                # Now append the new property at the end
                if new_args_text.strip() and not new_args_text.strip().endswith(','):
                    new_args_text += ','
                new_args_text += f'\n  {prop_name}: {new_prop},'
                
            else:
                # Property not found, inject it
                new_args_text = args_text
                if new_args_text.strip() and not new_args_text.strip().endswith(','):
                    new_args_text += ','
                new_args_text += f'\n  {prop_name}: {new_prop},'
                
            # Replace in original text
            text = text[:call_open_idx+1] + new_args_text + text[call_close_idx:]
            
            # Move index to end of modified call
            idx = call_open_idx + 1 + len(new_args_text) + 1
            
        return text

    text = process_calls(text, "CachedNetworkImage", "errorWidget", "(context, url, error) => Image.asset('assets/images/app_logo.png')")
    text = process_calls(text, "Image.network", "errorBuilder", "(context, error, stackTrace) => Image.asset('assets/images/app_logo.png')")

    if text != original_text:
        with open(filepath, 'w') as f:
            f.write(text)
        print(f"Updated {filepath}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            update_file(os.path.join(root, file))
