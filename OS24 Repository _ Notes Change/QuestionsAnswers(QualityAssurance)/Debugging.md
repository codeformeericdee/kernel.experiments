___ Bochs vs. QEMU ___

I find that Bochs is a useful tool to debug issues with addresses.

You can set a halt instruction, and Bochs will print a warning in the terminal

stating that it halted with an if=0, and you can verify that it arrived at that

specific address by then changing the halt instruction to a jmp $ to check if the

warning goes away.

= Something to keep in mind.