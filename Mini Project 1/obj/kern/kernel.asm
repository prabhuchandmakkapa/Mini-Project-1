
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6c 00 00 00       	call   f01000aa <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	56                   	push   %esi
f0100048:	53                   	push   %ebx
f0100049:	e8 7e 01 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f010004e:	81 c3 ba 12 01 00    	add    $0x112ba,%ebx
f0100054:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100057:	83 ec 08             	sub    $0x8,%esp
f010005a:	56                   	push   %esi
f010005b:	8d 83 b8 06 ff ff    	lea    -0xf948(%ebx),%eax
f0100061:	50                   	push   %eax
f0100062:	e8 45 0b 00 00       	call   f0100bac <cprintf>
	if (x > 0)
f0100067:	83 c4 10             	add    $0x10,%esp
f010006a:	85 f6                	test   %esi,%esi
f010006c:	7e 29                	jle    f0100097 <test_backtrace+0x57>
		test_backtrace(x-1);
f010006e:	83 ec 0c             	sub    $0xc,%esp
f0100071:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100074:	50                   	push   %eax
f0100075:	e8 c6 ff ff ff       	call   f0100040 <test_backtrace>
f010007a:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f010007d:	83 ec 08             	sub    $0x8,%esp
f0100080:	56                   	push   %esi
f0100081:	8d 83 d4 06 ff ff    	lea    -0xf92c(%ebx),%eax
f0100087:	50                   	push   %eax
f0100088:	e8 1f 0b 00 00       	call   f0100bac <cprintf>
}
f010008d:	83 c4 10             	add    $0x10,%esp
f0100090:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100093:	5b                   	pop    %ebx
f0100094:	5e                   	pop    %esi
f0100095:	5d                   	pop    %ebp
f0100096:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100097:	83 ec 04             	sub    $0x4,%esp
f010009a:	6a 00                	push   $0x0
f010009c:	6a 00                	push   $0x0
f010009e:	6a 00                	push   $0x0
f01000a0:	e8 23 08 00 00       	call   f01008c8 <mon_backtrace>
f01000a5:	83 c4 10             	add    $0x10,%esp
f01000a8:	eb d3                	jmp    f010007d <test_backtrace+0x3d>

f01000aa <i386_init>:

void
i386_init(void)
{
f01000aa:	f3 0f 1e fb          	endbr32 
f01000ae:	55                   	push   %ebp
f01000af:	89 e5                	mov    %esp,%ebp
f01000b1:	53                   	push   %ebx
f01000b2:	83 ec 08             	sub    $0x8,%esp
f01000b5:	e8 12 01 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f01000ba:	81 c3 4e 12 01 00    	add    $0x1124e,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000c0:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000c6:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000cc:	29 d0                	sub    %edx,%eax
f01000ce:	50                   	push   %eax
f01000cf:	6a 00                	push   $0x0
f01000d1:	52                   	push   %edx
f01000d2:	e8 d8 16 00 00       	call   f01017af <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d7:	e8 4b 05 00 00       	call   f0100627 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000dc:	83 c4 08             	add    $0x8,%esp
f01000df:	68 ac 1a 00 00       	push   $0x1aac
f01000e4:	8d 83 ef 06 ff ff    	lea    -0xf911(%ebx),%eax
f01000ea:	50                   	push   %eax
f01000eb:	e8 bc 0a 00 00       	call   f0100bac <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000f0:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000f7:	e8 44 ff ff ff       	call   f0100040 <test_backtrace>
f01000fc:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ff:	83 ec 0c             	sub    $0xc,%esp
f0100102:	6a 00                	push   $0x0
f0100104:	e8 dc 08 00 00       	call   f01009e5 <monitor>
f0100109:	83 c4 10             	add    $0x10,%esp
f010010c:	eb f1                	jmp    f01000ff <i386_init+0x55>

f010010e <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010010e:	f3 0f 1e fb          	endbr32 
f0100112:	55                   	push   %ebp
f0100113:	89 e5                	mov    %esp,%ebp
f0100115:	57                   	push   %edi
f0100116:	56                   	push   %esi
f0100117:	53                   	push   %ebx
f0100118:	83 ec 0c             	sub    $0xc,%esp
f010011b:	e8 ac 00 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100120:	81 c3 e8 11 01 00    	add    $0x111e8,%ebx
f0100126:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100129:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f010012f:	83 38 00             	cmpl   $0x0,(%eax)
f0100132:	74 0f                	je     f0100143 <_panic+0x35>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100134:	83 ec 0c             	sub    $0xc,%esp
f0100137:	6a 00                	push   $0x0
f0100139:	e8 a7 08 00 00       	call   f01009e5 <monitor>
f010013e:	83 c4 10             	add    $0x10,%esp
f0100141:	eb f1                	jmp    f0100134 <_panic+0x26>
	panicstr = fmt;
f0100143:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100145:	fa                   	cli    
f0100146:	fc                   	cld    
	va_start(ap, fmt);
f0100147:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010014a:	83 ec 04             	sub    $0x4,%esp
f010014d:	ff 75 0c             	pushl  0xc(%ebp)
f0100150:	ff 75 08             	pushl  0x8(%ebp)
f0100153:	8d 83 0a 07 ff ff    	lea    -0xf8f6(%ebx),%eax
f0100159:	50                   	push   %eax
f010015a:	e8 4d 0a 00 00       	call   f0100bac <cprintf>
	vcprintf(fmt, ap);
f010015f:	83 c4 08             	add    $0x8,%esp
f0100162:	56                   	push   %esi
f0100163:	57                   	push   %edi
f0100164:	e8 08 0a 00 00       	call   f0100b71 <vcprintf>
	cprintf("\n");
f0100169:	8d 83 46 07 ff ff    	lea    -0xf8ba(%ebx),%eax
f010016f:	89 04 24             	mov    %eax,(%esp)
f0100172:	e8 35 0a 00 00       	call   f0100bac <cprintf>
f0100177:	83 c4 10             	add    $0x10,%esp
f010017a:	eb b8                	jmp    f0100134 <_panic+0x26>

f010017c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010017c:	f3 0f 1e fb          	endbr32 
f0100180:	55                   	push   %ebp
f0100181:	89 e5                	mov    %esp,%ebp
f0100183:	56                   	push   %esi
f0100184:	53                   	push   %ebx
f0100185:	e8 42 00 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f010018a:	81 c3 7e 11 01 00    	add    $0x1117e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100190:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100193:	83 ec 04             	sub    $0x4,%esp
f0100196:	ff 75 0c             	pushl  0xc(%ebp)
f0100199:	ff 75 08             	pushl  0x8(%ebp)
f010019c:	8d 83 22 07 ff ff    	lea    -0xf8de(%ebx),%eax
f01001a2:	50                   	push   %eax
f01001a3:	e8 04 0a 00 00       	call   f0100bac <cprintf>
	vcprintf(fmt, ap);
f01001a8:	83 c4 08             	add    $0x8,%esp
f01001ab:	56                   	push   %esi
f01001ac:	ff 75 10             	pushl  0x10(%ebp)
f01001af:	e8 bd 09 00 00       	call   f0100b71 <vcprintf>
	cprintf("\n");
f01001b4:	8d 83 46 07 ff ff    	lea    -0xf8ba(%ebx),%eax
f01001ba:	89 04 24             	mov    %eax,(%esp)
f01001bd:	e8 ea 09 00 00       	call   f0100bac <cprintf>
	va_end(ap);
}
f01001c2:	83 c4 10             	add    $0x10,%esp
f01001c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001c8:	5b                   	pop    %ebx
f01001c9:	5e                   	pop    %esi
f01001ca:	5d                   	pop    %ebp
f01001cb:	c3                   	ret    

f01001cc <__x86.get_pc_thunk.bx>:
f01001cc:	8b 1c 24             	mov    (%esp),%ebx
f01001cf:	c3                   	ret    

f01001d0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001d0:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001d4:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001d9:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001da:	a8 01                	test   $0x1,%al
f01001dc:	74 0a                	je     f01001e8 <serial_proc_data+0x18>
f01001de:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001e3:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001e4:	0f b6 c0             	movzbl %al,%eax
f01001e7:	c3                   	ret    
		return -1;
f01001e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001ed:	c3                   	ret    

f01001ee <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ee:	55                   	push   %ebp
f01001ef:	89 e5                	mov    %esp,%ebp
f01001f1:	57                   	push   %edi
f01001f2:	56                   	push   %esi
f01001f3:	53                   	push   %ebx
f01001f4:	83 ec 1c             	sub    $0x1c,%esp
f01001f7:	e8 88 05 00 00       	call   f0100784 <__x86.get_pc_thunk.si>
f01001fc:	81 c6 0c 11 01 00    	add    $0x1110c,%esi
f0100202:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100204:	8d 1d 78 1d 00 00    	lea    0x1d78,%ebx
f010020a:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010020d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100210:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100213:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100216:	ff d0                	call   *%eax
f0100218:	83 f8 ff             	cmp    $0xffffffff,%eax
f010021b:	74 2b                	je     f0100248 <cons_intr+0x5a>
		if (c == 0)
f010021d:	85 c0                	test   %eax,%eax
f010021f:	74 f2                	je     f0100213 <cons_intr+0x25>
		cons.buf[cons.wpos++] = c;
f0100221:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100228:	8d 51 01             	lea    0x1(%ecx),%edx
f010022b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010022e:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100231:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100237:	b8 00 00 00 00       	mov    $0x0,%eax
f010023c:	0f 44 d0             	cmove  %eax,%edx
f010023f:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
f0100246:	eb cb                	jmp    f0100213 <cons_intr+0x25>
	}
}
f0100248:	83 c4 1c             	add    $0x1c,%esp
f010024b:	5b                   	pop    %ebx
f010024c:	5e                   	pop    %esi
f010024d:	5f                   	pop    %edi
f010024e:	5d                   	pop    %ebp
f010024f:	c3                   	ret    

f0100250 <kbd_proc_data>:
{
f0100250:	f3 0f 1e fb          	endbr32 
f0100254:	55                   	push   %ebp
f0100255:	89 e5                	mov    %esp,%ebp
f0100257:	56                   	push   %esi
f0100258:	53                   	push   %ebx
f0100259:	e8 6e ff ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010025e:	81 c3 aa 10 01 00    	add    $0x110aa,%ebx
f0100264:	ba 64 00 00 00       	mov    $0x64,%edx
f0100269:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010026a:	a8 01                	test   $0x1,%al
f010026c:	0f 84 fb 00 00 00    	je     f010036d <kbd_proc_data+0x11d>
	if (stat & KBS_TERR)
f0100272:	a8 20                	test   $0x20,%al
f0100274:	0f 85 fa 00 00 00    	jne    f0100374 <kbd_proc_data+0x124>
f010027a:	ba 60 00 00 00       	mov    $0x60,%edx
f010027f:	ec                   	in     (%dx),%al
f0100280:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100282:	3c e0                	cmp    $0xe0,%al
f0100284:	74 64                	je     f01002ea <kbd_proc_data+0x9a>
	} else if (data & 0x80) {
f0100286:	84 c0                	test   %al,%al
f0100288:	78 75                	js     f01002ff <kbd_proc_data+0xaf>
	} else if (shift & E0ESC) {
f010028a:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100290:	f6 c1 40             	test   $0x40,%cl
f0100293:	74 0e                	je     f01002a3 <kbd_proc_data+0x53>
		data |= 0x80;
f0100295:	83 c8 80             	or     $0xffffff80,%eax
f0100298:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010029a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010029d:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f01002a3:	0f b6 d2             	movzbl %dl,%edx
f01002a6:	0f b6 84 13 78 08 ff 	movzbl -0xf788(%ebx,%edx,1),%eax
f01002ad:	ff 
f01002ae:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f01002b4:	0f b6 8c 13 78 07 ff 	movzbl -0xf888(%ebx,%edx,1),%ecx
f01002bb:	ff 
f01002bc:	31 c8                	xor    %ecx,%eax
f01002be:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002c4:	89 c1                	mov    %eax,%ecx
f01002c6:	83 e1 03             	and    $0x3,%ecx
f01002c9:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002d0:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002d4:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002d7:	a8 08                	test   $0x8,%al
f01002d9:	74 65                	je     f0100340 <kbd_proc_data+0xf0>
		if ('a' <= c && c <= 'z')
f01002db:	89 f2                	mov    %esi,%edx
f01002dd:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002e0:	83 f9 19             	cmp    $0x19,%ecx
f01002e3:	77 4f                	ja     f0100334 <kbd_proc_data+0xe4>
			c += 'A' - 'a';
f01002e5:	83 ee 20             	sub    $0x20,%esi
f01002e8:	eb 0c                	jmp    f01002f6 <kbd_proc_data+0xa6>
		shift |= E0ESC;
f01002ea:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002f1:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002f6:	89 f0                	mov    %esi,%eax
f01002f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002fb:	5b                   	pop    %ebx
f01002fc:	5e                   	pop    %esi
f01002fd:	5d                   	pop    %ebp
f01002fe:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002ff:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100305:	89 ce                	mov    %ecx,%esi
f0100307:	83 e6 40             	and    $0x40,%esi
f010030a:	83 e0 7f             	and    $0x7f,%eax
f010030d:	85 f6                	test   %esi,%esi
f010030f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100312:	0f b6 d2             	movzbl %dl,%edx
f0100315:	0f b6 84 13 78 08 ff 	movzbl -0xf788(%ebx,%edx,1),%eax
f010031c:	ff 
f010031d:	83 c8 40             	or     $0x40,%eax
f0100320:	0f b6 c0             	movzbl %al,%eax
f0100323:	f7 d0                	not    %eax
f0100325:	21 c8                	and    %ecx,%eax
f0100327:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f010032d:	be 00 00 00 00       	mov    $0x0,%esi
f0100332:	eb c2                	jmp    f01002f6 <kbd_proc_data+0xa6>
		else if ('A' <= c && c <= 'Z')
f0100334:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100337:	8d 4e 20             	lea    0x20(%esi),%ecx
f010033a:	83 fa 1a             	cmp    $0x1a,%edx
f010033d:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100340:	f7 d0                	not    %eax
f0100342:	a8 06                	test   $0x6,%al
f0100344:	75 b0                	jne    f01002f6 <kbd_proc_data+0xa6>
f0100346:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010034c:	75 a8                	jne    f01002f6 <kbd_proc_data+0xa6>
		cprintf("Rebooting!\n");
f010034e:	83 ec 0c             	sub    $0xc,%esp
f0100351:	8d 83 3c 07 ff ff    	lea    -0xf8c4(%ebx),%eax
f0100357:	50                   	push   %eax
f0100358:	e8 4f 08 00 00       	call   f0100bac <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100362:	ba 92 00 00 00       	mov    $0x92,%edx
f0100367:	ee                   	out    %al,(%dx)
}
f0100368:	83 c4 10             	add    $0x10,%esp
f010036b:	eb 89                	jmp    f01002f6 <kbd_proc_data+0xa6>
		return -1;
f010036d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100372:	eb 82                	jmp    f01002f6 <kbd_proc_data+0xa6>
		return -1;
f0100374:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100379:	e9 78 ff ff ff       	jmp    f01002f6 <kbd_proc_data+0xa6>

f010037e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010037e:	55                   	push   %ebp
f010037f:	89 e5                	mov    %esp,%ebp
f0100381:	57                   	push   %edi
f0100382:	56                   	push   %esi
f0100383:	53                   	push   %ebx
f0100384:	83 ec 1c             	sub    $0x1c,%esp
f0100387:	e8 40 fe ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010038c:	81 c3 7c 0f 01 00    	add    $0x10f7c,%ebx
f0100392:	89 c7                	mov    %eax,%edi
	for (i = 0;
f0100394:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100399:	b9 84 00 00 00       	mov    $0x84,%ecx
f010039e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003a3:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003a4:	a8 20                	test   $0x20,%al
f01003a6:	75 13                	jne    f01003bb <cons_putc+0x3d>
f01003a8:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003ae:	7f 0b                	jg     f01003bb <cons_putc+0x3d>
f01003b0:	89 ca                	mov    %ecx,%edx
f01003b2:	ec                   	in     (%dx),%al
f01003b3:	ec                   	in     (%dx),%al
f01003b4:	ec                   	in     (%dx),%al
f01003b5:	ec                   	in     (%dx),%al
	     i++)
f01003b6:	83 c6 01             	add    $0x1,%esi
f01003b9:	eb e3                	jmp    f010039e <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f01003bb:	89 f8                	mov    %edi,%eax
f01003bd:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003c5:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003c6:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003cb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003d0:	ba 79 03 00 00       	mov    $0x379,%edx
f01003d5:	ec                   	in     (%dx),%al
f01003d6:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003dc:	7f 0f                	jg     f01003ed <cons_putc+0x6f>
f01003de:	84 c0                	test   %al,%al
f01003e0:	78 0b                	js     f01003ed <cons_putc+0x6f>
f01003e2:	89 ca                	mov    %ecx,%edx
f01003e4:	ec                   	in     (%dx),%al
f01003e5:	ec                   	in     (%dx),%al
f01003e6:	ec                   	in     (%dx),%al
f01003e7:	ec                   	in     (%dx),%al
f01003e8:	83 c6 01             	add    $0x1,%esi
f01003eb:	eb e3                	jmp    f01003d0 <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ed:	ba 78 03 00 00       	mov    $0x378,%edx
f01003f2:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01003f6:	ee                   	out    %al,(%dx)
f01003f7:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003fc:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100401:	ee                   	out    %al,(%dx)
f0100402:	b8 08 00 00 00       	mov    $0x8,%eax
f0100407:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100408:	89 f8                	mov    %edi,%eax
f010040a:	80 cc 07             	or     $0x7,%ah
f010040d:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100413:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100416:	89 f8                	mov    %edi,%eax
f0100418:	0f b6 c0             	movzbl %al,%eax
f010041b:	89 f9                	mov    %edi,%ecx
f010041d:	80 f9 0a             	cmp    $0xa,%cl
f0100420:	0f 84 e2 00 00 00    	je     f0100508 <cons_putc+0x18a>
f0100426:	83 f8 0a             	cmp    $0xa,%eax
f0100429:	7f 46                	jg     f0100471 <cons_putc+0xf3>
f010042b:	83 f8 08             	cmp    $0x8,%eax
f010042e:	0f 84 a8 00 00 00    	je     f01004dc <cons_putc+0x15e>
f0100434:	83 f8 09             	cmp    $0x9,%eax
f0100437:	0f 85 d8 00 00 00    	jne    f0100515 <cons_putc+0x197>
		cons_putc(' ');
f010043d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100442:	e8 37 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100447:	b8 20 00 00 00       	mov    $0x20,%eax
f010044c:	e8 2d ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100451:	b8 20 00 00 00       	mov    $0x20,%eax
f0100456:	e8 23 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f010045b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100460:	e8 19 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100465:	b8 20 00 00 00       	mov    $0x20,%eax
f010046a:	e8 0f ff ff ff       	call   f010037e <cons_putc>
		break;
f010046f:	eb 26                	jmp    f0100497 <cons_putc+0x119>
	switch (c & 0xff) {
f0100471:	83 f8 0d             	cmp    $0xd,%eax
f0100474:	0f 85 9b 00 00 00    	jne    f0100515 <cons_putc+0x197>
		crt_pos -= (crt_pos % CRT_COLS);
f010047a:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100481:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100487:	c1 e8 16             	shr    $0x16,%eax
f010048a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010048d:	c1 e0 04             	shl    $0x4,%eax
f0100490:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100497:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010049e:	cf 07 
f01004a0:	0f 87 92 00 00 00    	ja     f0100538 <cons_putc+0x1ba>
	outb(addr_6845, 14);
f01004a6:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f01004ac:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b1:	89 ca                	mov    %ecx,%edx
f01004b3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b4:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f01004bb:	8d 71 01             	lea    0x1(%ecx),%esi
f01004be:	89 d8                	mov    %ebx,%eax
f01004c0:	66 c1 e8 08          	shr    $0x8,%ax
f01004c4:	89 f2                	mov    %esi,%edx
f01004c6:	ee                   	out    %al,(%dx)
f01004c7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cc:	89 ca                	mov    %ecx,%edx
f01004ce:	ee                   	out    %al,(%dx)
f01004cf:	89 d8                	mov    %ebx,%eax
f01004d1:	89 f2                	mov    %esi,%edx
f01004d3:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d7:	5b                   	pop    %ebx
f01004d8:	5e                   	pop    %esi
f01004d9:	5f                   	pop    %edi
f01004da:	5d                   	pop    %ebp
f01004db:	c3                   	ret    
		if (crt_pos > 0) {
f01004dc:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01004e3:	66 85 c0             	test   %ax,%ax
f01004e6:	74 be                	je     f01004a6 <cons_putc+0x128>
			crt_pos--;
f01004e8:	83 e8 01             	sub    $0x1,%eax
f01004eb:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004f2:	0f b7 c0             	movzwl %ax,%eax
f01004f5:	89 fa                	mov    %edi,%edx
f01004f7:	b2 00                	mov    $0x0,%dl
f01004f9:	83 ca 20             	or     $0x20,%edx
f01004fc:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f0100502:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100506:	eb 8f                	jmp    f0100497 <cons_putc+0x119>
		crt_pos += CRT_COLS;
f0100508:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f010050f:	50 
f0100510:	e9 65 ff ff ff       	jmp    f010047a <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100515:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010051c:	8d 50 01             	lea    0x1(%eax),%edx
f010051f:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100526:	0f b7 c0             	movzwl %ax,%eax
f0100529:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010052f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100533:	e9 5f ff ff ff       	jmp    f0100497 <cons_putc+0x119>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100538:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010053e:	83 ec 04             	sub    $0x4,%esp
f0100541:	68 00 0f 00 00       	push   $0xf00
f0100546:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010054c:	52                   	push   %edx
f010054d:	50                   	push   %eax
f010054e:	e8 a8 12 00 00       	call   f01017fb <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100553:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f0100559:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010055f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100565:	83 c4 10             	add    $0x10,%esp
f0100568:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010056d:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100570:	39 d0                	cmp    %edx,%eax
f0100572:	75 f4                	jne    f0100568 <cons_putc+0x1ea>
		crt_pos -= CRT_COLS;
f0100574:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010057b:	50 
f010057c:	e9 25 ff ff ff       	jmp    f01004a6 <cons_putc+0x128>

f0100581 <serial_intr>:
{
f0100581:	f3 0f 1e fb          	endbr32 
f0100585:	e8 f6 01 00 00       	call   f0100780 <__x86.get_pc_thunk.ax>
f010058a:	05 7e 0d 01 00       	add    $0x10d7e,%eax
	if (serial_exists)
f010058f:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100596:	75 01                	jne    f0100599 <serial_intr+0x18>
f0100598:	c3                   	ret    
{
f0100599:	55                   	push   %ebp
f010059a:	89 e5                	mov    %esp,%ebp
f010059c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010059f:	8d 80 c8 ee fe ff    	lea    -0x11138(%eax),%eax
f01005a5:	e8 44 fc ff ff       	call   f01001ee <cons_intr>
}
f01005aa:	c9                   	leave  
f01005ab:	c3                   	ret    

f01005ac <kbd_intr>:
{
f01005ac:	f3 0f 1e fb          	endbr32 
f01005b0:	55                   	push   %ebp
f01005b1:	89 e5                	mov    %esp,%ebp
f01005b3:	83 ec 08             	sub    $0x8,%esp
f01005b6:	e8 c5 01 00 00       	call   f0100780 <__x86.get_pc_thunk.ax>
f01005bb:	05 4d 0d 01 00       	add    $0x10d4d,%eax
	cons_intr(kbd_proc_data);
f01005c0:	8d 80 48 ef fe ff    	lea    -0x110b8(%eax),%eax
f01005c6:	e8 23 fc ff ff       	call   f01001ee <cons_intr>
}
f01005cb:	c9                   	leave  
f01005cc:	c3                   	ret    

f01005cd <cons_getc>:
{
f01005cd:	f3 0f 1e fb          	endbr32 
f01005d1:	55                   	push   %ebp
f01005d2:	89 e5                	mov    %esp,%ebp
f01005d4:	53                   	push   %ebx
f01005d5:	83 ec 04             	sub    $0x4,%esp
f01005d8:	e8 ef fb ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01005dd:	81 c3 2b 0d 01 00    	add    $0x10d2b,%ebx
	serial_intr();
f01005e3:	e8 99 ff ff ff       	call   f0100581 <serial_intr>
	kbd_intr();
f01005e8:	e8 bf ff ff ff       	call   f01005ac <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005ed:	8b 83 78 1f 00 00    	mov    0x1f78(%ebx),%eax
	return 0;
f01005f3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005f8:	3b 83 7c 1f 00 00    	cmp    0x1f7c(%ebx),%eax
f01005fe:	74 1f                	je     f010061f <cons_getc+0x52>
		c = cons.buf[cons.rpos++];
f0100600:	8d 48 01             	lea    0x1(%eax),%ecx
f0100603:	0f b6 94 03 78 1d 00 	movzbl 0x1d78(%ebx,%eax,1),%edx
f010060a:	00 
			cons.rpos = 0;
f010060b:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100611:	b8 00 00 00 00       	mov    $0x0,%eax
f0100616:	0f 44 c8             	cmove  %eax,%ecx
f0100619:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
}
f010061f:	89 d0                	mov    %edx,%eax
f0100621:	83 c4 04             	add    $0x4,%esp
f0100624:	5b                   	pop    %ebx
f0100625:	5d                   	pop    %ebp
f0100626:	c3                   	ret    

f0100627 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100627:	f3 0f 1e fb          	endbr32 
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
f010062e:	57                   	push   %edi
f010062f:	56                   	push   %esi
f0100630:	53                   	push   %ebx
f0100631:	83 ec 1c             	sub    $0x1c,%esp
f0100634:	e8 93 fb ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100639:	81 c3 cf 0c 01 00    	add    $0x10ccf,%ebx
	was = *cp;
f010063f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100646:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010064d:	5a a5 
	if (*cp != 0xA55A) {
f010064f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100656:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010065a:	0f 84 bc 00 00 00    	je     f010071c <cons_init+0xf5>
		addr_6845 = MONO_BASE;
f0100660:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f0100667:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066a:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100671:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f0100677:	b8 0e 00 00 00       	mov    $0xe,%eax
f010067c:	89 fa                	mov    %edi,%edx
f010067e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010067f:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100682:	89 ca                	mov    %ecx,%edx
f0100684:	ec                   	in     (%dx),%al
f0100685:	0f b6 f0             	movzbl %al,%esi
f0100688:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100690:	89 fa                	mov    %edi,%edx
f0100692:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100693:	89 ca                	mov    %ecx,%edx
f0100695:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100696:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100699:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f010069f:	0f b6 c0             	movzbl %al,%eax
f01006a2:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f01006a4:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ab:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006b0:	89 c8                	mov    %ecx,%eax
f01006b2:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006b7:	ee                   	out    %al,(%dx)
f01006b8:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006bd:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006c2:	89 fa                	mov    %edi,%edx
f01006c4:	ee                   	out    %al,(%dx)
f01006c5:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006d5:	89 c8                	mov    %ecx,%eax
f01006d7:	89 f2                	mov    %esi,%edx
f01006d9:	ee                   	out    %al,(%dx)
f01006da:	b8 03 00 00 00       	mov    $0x3,%eax
f01006df:	89 fa                	mov    %edi,%edx
f01006e1:	ee                   	out    %al,(%dx)
f01006e2:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006e7:	89 c8                	mov    %ecx,%eax
f01006e9:	ee                   	out    %al,(%dx)
f01006ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ef:	89 f2                	mov    %esi,%edx
f01006f1:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006f7:	ec                   	in     (%dx),%al
f01006f8:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006fa:	3c ff                	cmp    $0xff,%al
f01006fc:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f0100703:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100708:	ec                   	in     (%dx),%al
f0100709:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010070e:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010070f:	80 f9 ff             	cmp    $0xff,%cl
f0100712:	74 25                	je     f0100739 <cons_init+0x112>
		cprintf("Serial port does not exist!\n");
}
f0100714:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100717:	5b                   	pop    %ebx
f0100718:	5e                   	pop    %esi
f0100719:	5f                   	pop    %edi
f010071a:	5d                   	pop    %ebp
f010071b:	c3                   	ret    
		*cp = was;
f010071c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100723:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f010072a:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010072d:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100734:	e9 38 ff ff ff       	jmp    f0100671 <cons_init+0x4a>
		cprintf("Serial port does not exist!\n");
f0100739:	83 ec 0c             	sub    $0xc,%esp
f010073c:	8d 83 48 07 ff ff    	lea    -0xf8b8(%ebx),%eax
f0100742:	50                   	push   %eax
f0100743:	e8 64 04 00 00       	call   f0100bac <cprintf>
f0100748:	83 c4 10             	add    $0x10,%esp
}
f010074b:	eb c7                	jmp    f0100714 <cons_init+0xed>

f010074d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010074d:	f3 0f 1e fb          	endbr32 
f0100751:	55                   	push   %ebp
f0100752:	89 e5                	mov    %esp,%ebp
f0100754:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100757:	8b 45 08             	mov    0x8(%ebp),%eax
f010075a:	e8 1f fc ff ff       	call   f010037e <cons_putc>
}
f010075f:	c9                   	leave  
f0100760:	c3                   	ret    

f0100761 <getchar>:

int
getchar(void)
{
f0100761:	f3 0f 1e fb          	endbr32 
f0100765:	55                   	push   %ebp
f0100766:	89 e5                	mov    %esp,%ebp
f0100768:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010076b:	e8 5d fe ff ff       	call   f01005cd <cons_getc>
f0100770:	85 c0                	test   %eax,%eax
f0100772:	74 f7                	je     f010076b <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100774:	c9                   	leave  
f0100775:	c3                   	ret    

f0100776 <iscons>:

int
iscons(int fdnum)
{
f0100776:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f010077a:	b8 01 00 00 00       	mov    $0x1,%eax
f010077f:	c3                   	ret    

f0100780 <__x86.get_pc_thunk.ax>:
f0100780:	8b 04 24             	mov    (%esp),%eax
f0100783:	c3                   	ret    

f0100784 <__x86.get_pc_thunk.si>:
f0100784:	8b 34 24             	mov    (%esp),%esi
f0100787:	c3                   	ret    

f0100788 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100788:	f3 0f 1e fb          	endbr32 
f010078c:	55                   	push   %ebp
f010078d:	89 e5                	mov    %esp,%ebp
f010078f:	56                   	push   %esi
f0100790:	53                   	push   %ebx
f0100791:	e8 36 fa ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100796:	81 c3 72 0b 01 00    	add    $0x10b72,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010079c:	83 ec 04             	sub    $0x4,%esp
f010079f:	8d 83 78 09 ff ff    	lea    -0xf688(%ebx),%eax
f01007a5:	50                   	push   %eax
f01007a6:	8d 83 96 09 ff ff    	lea    -0xf66a(%ebx),%eax
f01007ac:	50                   	push   %eax
f01007ad:	8d b3 9b 09 ff ff    	lea    -0xf665(%ebx),%esi
f01007b3:	56                   	push   %esi
f01007b4:	e8 f3 03 00 00       	call   f0100bac <cprintf>
f01007b9:	83 c4 0c             	add    $0xc,%esp
f01007bc:	8d 83 34 0a ff ff    	lea    -0xf5cc(%ebx),%eax
f01007c2:	50                   	push   %eax
f01007c3:	8d 83 a4 09 ff ff    	lea    -0xf65c(%ebx),%eax
f01007c9:	50                   	push   %eax
f01007ca:	56                   	push   %esi
f01007cb:	e8 dc 03 00 00       	call   f0100bac <cprintf>
f01007d0:	83 c4 0c             	add    $0xc,%esp
f01007d3:	8d 83 5c 0a ff ff    	lea    -0xf5a4(%ebx),%eax
f01007d9:	50                   	push   %eax
f01007da:	8d 83 ad 09 ff ff    	lea    -0xf653(%ebx),%eax
f01007e0:	50                   	push   %eax
f01007e1:	56                   	push   %esi
f01007e2:	e8 c5 03 00 00       	call   f0100bac <cprintf>
	return 0;
}
f01007e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007ef:	5b                   	pop    %ebx
f01007f0:	5e                   	pop    %esi
f01007f1:	5d                   	pop    %ebp
f01007f2:	c3                   	ret    

f01007f3 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007f3:	f3 0f 1e fb          	endbr32 
f01007f7:	55                   	push   %ebp
f01007f8:	89 e5                	mov    %esp,%ebp
f01007fa:	57                   	push   %edi
f01007fb:	56                   	push   %esi
f01007fc:	53                   	push   %ebx
f01007fd:	83 ec 18             	sub    $0x18,%esp
f0100800:	e8 c7 f9 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100805:	81 c3 03 0b 01 00    	add    $0x10b03,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010080b:	8d 83 b7 09 ff ff    	lea    -0xf649(%ebx),%eax
f0100811:	50                   	push   %eax
f0100812:	e8 95 03 00 00       	call   f0100bac <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100817:	83 c4 08             	add    $0x8,%esp
f010081a:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100820:	8d 83 84 0a ff ff    	lea    -0xf57c(%ebx),%eax
f0100826:	50                   	push   %eax
f0100827:	e8 80 03 00 00       	call   f0100bac <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010082c:	83 c4 0c             	add    $0xc,%esp
f010082f:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100835:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f010083b:	50                   	push   %eax
f010083c:	57                   	push   %edi
f010083d:	8d 83 ac 0a ff ff    	lea    -0xf554(%ebx),%eax
f0100843:	50                   	push   %eax
f0100844:	e8 63 03 00 00       	call   f0100bac <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100849:	83 c4 0c             	add    $0xc,%esp
f010084c:	c7 c0 b7 19 10 f0    	mov    $0xf01019b7,%eax
f0100852:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100858:	52                   	push   %edx
f0100859:	50                   	push   %eax
f010085a:	8d 83 d0 0a ff ff    	lea    -0xf530(%ebx),%eax
f0100860:	50                   	push   %eax
f0100861:	e8 46 03 00 00       	call   f0100bac <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100866:	83 c4 0c             	add    $0xc,%esp
f0100869:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f010086f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100875:	52                   	push   %edx
f0100876:	50                   	push   %eax
f0100877:	8d 83 f4 0a ff ff    	lea    -0xf50c(%ebx),%eax
f010087d:	50                   	push   %eax
f010087e:	e8 29 03 00 00       	call   f0100bac <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100883:	83 c4 0c             	add    $0xc,%esp
f0100886:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f010088c:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100892:	50                   	push   %eax
f0100893:	56                   	push   %esi
f0100894:	8d 83 18 0b ff ff    	lea    -0xf4e8(%ebx),%eax
f010089a:	50                   	push   %eax
f010089b:	e8 0c 03 00 00       	call   f0100bac <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008a0:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008a3:	29 fe                	sub    %edi,%esi
f01008a5:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008ab:	c1 fe 0a             	sar    $0xa,%esi
f01008ae:	56                   	push   %esi
f01008af:	8d 83 3c 0b ff ff    	lea    -0xf4c4(%ebx),%eax
f01008b5:	50                   	push   %eax
f01008b6:	e8 f1 02 00 00       	call   f0100bac <cprintf>
	return 0;
}
f01008bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008c3:	5b                   	pop    %ebx
f01008c4:	5e                   	pop    %esi
f01008c5:	5f                   	pop    %edi
f01008c6:	5d                   	pop    %ebp
f01008c7:	c3                   	ret    

f01008c8 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008c8:	f3 0f 1e fb          	endbr32 
f01008cc:	55                   	push   %ebp
f01008cd:	89 e5                	mov    %esp,%ebp
f01008cf:	57                   	push   %edi
f01008d0:	56                   	push   %esi
f01008d1:	53                   	push   %ebx
f01008d2:	83 ec 4c             	sub    $0x4c,%esp
f01008d5:	e8 f2 f8 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01008da:	81 c3 2e 0a 01 00    	add    $0x10a2e,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008e0:	89 e8                	mov    %ebp,%eax
	// Your code here.
	// The data structure to save information about EIP
	struct Eipdebuginfo info;
	uint32_t arg[4];
	uint32_t* ebp = (uint32_t*)read_ebp();
f01008e2:	89 c7                	mov    %eax,%edi
	while(ebp != NULL)
	{
		uint32_t eip = *(ebp + 1);
		for(int i = 0; i < 4; i++)
			arg[i] = *(ebp + i + 2);
		cprintf("ebp %08x eip %08x args ", ebp, eip);
f01008e4:	8d 83 d0 09 ff ff    	lea    -0xf630(%ebx),%eax
f01008ea:	89 45 a8             	mov    %eax,-0x58(%ebp)
		for(int i = 0; i < 4; i++)
			cprintf("%08x ", arg[i]);
f01008ed:	8d 83 e8 09 ff ff    	lea    -0xf618(%ebx),%eax
f01008f3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
	while(ebp != NULL)
f01008f6:	eb 14                	jmp    f010090c <mon_backtrace+0x44>
			cprintf("%s:%d: ", info.eip_file, info.eip_line);
			cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
			cprintf("+%d\n", eip - (uint32_t)info.eip_fn_addr);
		}
		else
			cprintf("Error happened when reading symbol table\n");
f01008f8:	83 ec 0c             	sub    $0xc,%esp
f01008fb:	8d 83 68 0b ff ff    	lea    -0xf498(%ebx),%eax
f0100901:	50                   	push   %eax
f0100902:	e8 a5 02 00 00       	call   f0100bac <cprintf>
f0100907:	83 c4 10             	add    $0x10,%esp
		ebp = (uint32_t*) (*ebp);
f010090a:	8b 3f                	mov    (%edi),%edi
	while(ebp != NULL)
f010090c:	85 ff                	test   %edi,%edi
f010090e:	0f 84 c4 00 00 00    	je     f01009d8 <mon_backtrace+0x110>
		uint32_t eip = *(ebp + 1);
f0100914:	8b 57 04             	mov    0x4(%edi),%edx
f0100917:	89 55 b0             	mov    %edx,-0x50(%ebp)
			arg[i] = *(ebp + i + 2);
f010091a:	8b 47 08             	mov    0x8(%edi),%eax
f010091d:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0100920:	8b 47 0c             	mov    0xc(%edi),%eax
f0100923:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100926:	8b 47 10             	mov    0x10(%edi),%eax
f0100929:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010092c:	8b 47 14             	mov    0x14(%edi),%eax
f010092f:	89 45 cc             	mov    %eax,-0x34(%ebp)
		cprintf("ebp %08x eip %08x args ", ebp, eip);
f0100932:	83 ec 04             	sub    $0x4,%esp
f0100935:	52                   	push   %edx
f0100936:	57                   	push   %edi
f0100937:	ff 75 a8             	pushl  -0x58(%ebp)
f010093a:	e8 6d 02 00 00       	call   f0100bac <cprintf>
f010093f:	8d 75 c0             	lea    -0x40(%ebp),%esi
f0100942:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100945:	83 c4 10             	add    $0x10,%esp
f0100948:	89 7d ac             	mov    %edi,-0x54(%ebp)
f010094b:	89 c7                	mov    %eax,%edi
			cprintf("%08x ", arg[i]);
f010094d:	83 ec 08             	sub    $0x8,%esp
f0100950:	ff 36                	pushl  (%esi)
f0100952:	ff 75 b4             	pushl  -0x4c(%ebp)
f0100955:	e8 52 02 00 00       	call   f0100bac <cprintf>
f010095a:	83 c6 04             	add    $0x4,%esi
		for(int i = 0; i < 4; i++)
f010095d:	83 c4 10             	add    $0x10,%esp
f0100960:	39 f7                	cmp    %esi,%edi
f0100962:	75 e9                	jne    f010094d <mon_backtrace+0x85>
f0100964:	8b 7d ac             	mov    -0x54(%ebp),%edi
		cprintf("\n");
f0100967:	83 ec 0c             	sub    $0xc,%esp
f010096a:	8d 83 46 07 ff ff    	lea    -0xf8ba(%ebx),%eax
f0100970:	50                   	push   %eax
f0100971:	e8 36 02 00 00       	call   f0100bac <cprintf>
		if(debuginfo_eip(eip, &info) == 0)
f0100976:	83 c4 08             	add    $0x8,%esp
f0100979:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010097c:	50                   	push   %eax
f010097d:	8b 75 b0             	mov    -0x50(%ebp),%esi
f0100980:	56                   	push   %esi
f0100981:	e8 33 03 00 00       	call   f0100cb9 <debuginfo_eip>
f0100986:	83 c4 10             	add    $0x10,%esp
f0100989:	85 c0                	test   %eax,%eax
f010098b:	0f 85 67 ff ff ff    	jne    f01008f8 <mon_backtrace+0x30>
			cprintf("%s:%d: ", info.eip_file, info.eip_line);
f0100991:	83 ec 04             	sub    $0x4,%esp
f0100994:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100997:	ff 75 d0             	pushl  -0x30(%ebp)
f010099a:	8d 83 1a 07 ff ff    	lea    -0xf8e6(%ebx),%eax
f01009a0:	50                   	push   %eax
f01009a1:	e8 06 02 00 00       	call   f0100bac <cprintf>
			cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
f01009a6:	83 c4 0c             	add    $0xc,%esp
f01009a9:	ff 75 d8             	pushl  -0x28(%ebp)
f01009ac:	ff 75 dc             	pushl  -0x24(%ebp)
f01009af:	8d 83 ee 09 ff ff    	lea    -0xf612(%ebx),%eax
f01009b5:	50                   	push   %eax
f01009b6:	e8 f1 01 00 00       	call   f0100bac <cprintf>
			cprintf("+%d\n", eip - (uint32_t)info.eip_fn_addr);
f01009bb:	83 c4 08             	add    $0x8,%esp
f01009be:	89 f0                	mov    %esi,%eax
f01009c0:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01009c3:	50                   	push   %eax
f01009c4:	8d 83 f3 09 ff ff    	lea    -0xf60d(%ebx),%eax
f01009ca:	50                   	push   %eax
f01009cb:	e8 dc 01 00 00       	call   f0100bac <cprintf>
f01009d0:	83 c4 10             	add    $0x10,%esp
f01009d3:	e9 32 ff ff ff       	jmp    f010090a <mon_backtrace+0x42>
	}
	return 0;
}
f01009d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01009dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009e0:	5b                   	pop    %ebx
f01009e1:	5e                   	pop    %esi
f01009e2:	5f                   	pop    %edi
f01009e3:	5d                   	pop    %ebp
f01009e4:	c3                   	ret    

f01009e5 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009e5:	f3 0f 1e fb          	endbr32 
f01009e9:	55                   	push   %ebp
f01009ea:	89 e5                	mov    %esp,%ebp
f01009ec:	57                   	push   %edi
f01009ed:	56                   	push   %esi
f01009ee:	53                   	push   %ebx
f01009ef:	83 ec 68             	sub    $0x68,%esp
f01009f2:	e8 d5 f7 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01009f7:	81 c3 11 09 01 00    	add    $0x10911,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009fd:	8d 83 94 0b ff ff    	lea    -0xf46c(%ebx),%eax
f0100a03:	50                   	push   %eax
f0100a04:	e8 a3 01 00 00       	call   f0100bac <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100a09:	8d 83 b8 0b ff ff    	lea    -0xf448(%ebx),%eax
f0100a0f:	89 04 24             	mov    %eax,(%esp)
f0100a12:	e8 95 01 00 00       	call   f0100bac <cprintf>
f0100a17:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100a1a:	8d 83 fc 09 ff ff    	lea    -0xf604(%ebx),%eax
f0100a20:	89 45 a0             	mov    %eax,-0x60(%ebp)
f0100a23:	e9 d1 00 00 00       	jmp    f0100af9 <monitor+0x114>
f0100a28:	83 ec 08             	sub    $0x8,%esp
f0100a2b:	0f be c0             	movsbl %al,%eax
f0100a2e:	50                   	push   %eax
f0100a2f:	ff 75 a0             	pushl  -0x60(%ebp)
f0100a32:	e8 33 0d 00 00       	call   f010176a <strchr>
f0100a37:	83 c4 10             	add    $0x10,%esp
f0100a3a:	85 c0                	test   %eax,%eax
f0100a3c:	74 6d                	je     f0100aab <monitor+0xc6>
			*buf++ = 0;
f0100a3e:	c6 06 00             	movb   $0x0,(%esi)
f0100a41:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100a44:	8d 76 01             	lea    0x1(%esi),%esi
f0100a47:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a4a:	0f b6 06             	movzbl (%esi),%eax
f0100a4d:	84 c0                	test   %al,%al
f0100a4f:	75 d7                	jne    f0100a28 <monitor+0x43>
	argv[argc] = 0;
f0100a51:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f0100a58:	00 
	if (argc == 0)
f0100a59:	85 ff                	test   %edi,%edi
f0100a5b:	0f 84 98 00 00 00    	je     f0100af9 <monitor+0x114>
f0100a61:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a67:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a6c:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100a6f:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a71:	83 ec 08             	sub    $0x8,%esp
f0100a74:	ff 36                	pushl  (%esi)
f0100a76:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a79:	e8 86 0c 00 00       	call   f0101704 <strcmp>
f0100a7e:	83 c4 10             	add    $0x10,%esp
f0100a81:	85 c0                	test   %eax,%eax
f0100a83:	0f 84 99 00 00 00    	je     f0100b22 <monitor+0x13d>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a89:	83 c7 01             	add    $0x1,%edi
f0100a8c:	83 c6 0c             	add    $0xc,%esi
f0100a8f:	83 ff 03             	cmp    $0x3,%edi
f0100a92:	75 dd                	jne    f0100a71 <monitor+0x8c>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a94:	83 ec 08             	sub    $0x8,%esp
f0100a97:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a9a:	8d 83 1e 0a ff ff    	lea    -0xf5e2(%ebx),%eax
f0100aa0:	50                   	push   %eax
f0100aa1:	e8 06 01 00 00       	call   f0100bac <cprintf>
	return 0;
f0100aa6:	83 c4 10             	add    $0x10,%esp
f0100aa9:	eb 4e                	jmp    f0100af9 <monitor+0x114>
		if (*buf == 0)
f0100aab:	80 3e 00             	cmpb   $0x0,(%esi)
f0100aae:	74 a1                	je     f0100a51 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f0100ab0:	83 ff 0f             	cmp    $0xf,%edi
f0100ab3:	74 30                	je     f0100ae5 <monitor+0x100>
		argv[argc++] = buf;
f0100ab5:	8d 47 01             	lea    0x1(%edi),%eax
f0100ab8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100abb:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100abf:	0f b6 06             	movzbl (%esi),%eax
f0100ac2:	84 c0                	test   %al,%al
f0100ac4:	74 81                	je     f0100a47 <monitor+0x62>
f0100ac6:	83 ec 08             	sub    $0x8,%esp
f0100ac9:	0f be c0             	movsbl %al,%eax
f0100acc:	50                   	push   %eax
f0100acd:	ff 75 a0             	pushl  -0x60(%ebp)
f0100ad0:	e8 95 0c 00 00       	call   f010176a <strchr>
f0100ad5:	83 c4 10             	add    $0x10,%esp
f0100ad8:	85 c0                	test   %eax,%eax
f0100ada:	0f 85 67 ff ff ff    	jne    f0100a47 <monitor+0x62>
			buf++;
f0100ae0:	83 c6 01             	add    $0x1,%esi
f0100ae3:	eb da                	jmp    f0100abf <monitor+0xda>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ae5:	83 ec 08             	sub    $0x8,%esp
f0100ae8:	6a 10                	push   $0x10
f0100aea:	8d 83 01 0a ff ff    	lea    -0xf5ff(%ebx),%eax
f0100af0:	50                   	push   %eax
f0100af1:	e8 b6 00 00 00       	call   f0100bac <cprintf>
			return 0;
f0100af6:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100af9:	8d bb f8 09 ff ff    	lea    -0xf608(%ebx),%edi
f0100aff:	83 ec 0c             	sub    $0xc,%esp
f0100b02:	57                   	push   %edi
f0100b03:	e8 f1 09 00 00       	call   f01014f9 <readline>
		if (buf != NULL)
f0100b08:	83 c4 10             	add    $0x10,%esp
f0100b0b:	85 c0                	test   %eax,%eax
f0100b0d:	74 f0                	je     f0100aff <monitor+0x11a>
f0100b0f:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f0100b11:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100b18:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b1d:	e9 28 ff ff ff       	jmp    f0100a4a <monitor+0x65>
f0100b22:	89 f8                	mov    %edi,%eax
f0100b24:	8b 7d a4             	mov    -0x5c(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100b27:	83 ec 04             	sub    $0x4,%esp
f0100b2a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b2d:	ff 75 08             	pushl  0x8(%ebp)
f0100b30:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100b33:	52                   	push   %edx
f0100b34:	57                   	push   %edi
f0100b35:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100b3c:	83 c4 10             	add    $0x10,%esp
f0100b3f:	85 c0                	test   %eax,%eax
f0100b41:	79 b6                	jns    f0100af9 <monitor+0x114>
				break;
	}
}
f0100b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b46:	5b                   	pop    %ebx
f0100b47:	5e                   	pop    %esi
f0100b48:	5f                   	pop    %edi
f0100b49:	5d                   	pop    %ebp
f0100b4a:	c3                   	ret    

f0100b4b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100b4b:	f3 0f 1e fb          	endbr32 
f0100b4f:	55                   	push   %ebp
f0100b50:	89 e5                	mov    %esp,%ebp
f0100b52:	53                   	push   %ebx
f0100b53:	83 ec 10             	sub    $0x10,%esp
f0100b56:	e8 71 f6 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100b5b:	81 c3 ad 07 01 00    	add    $0x107ad,%ebx
	cputchar(ch);
f0100b61:	ff 75 08             	pushl  0x8(%ebp)
f0100b64:	e8 e4 fb ff ff       	call   f010074d <cputchar>
	*cnt++;
}
f0100b69:	83 c4 10             	add    $0x10,%esp
f0100b6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b6f:	c9                   	leave  
f0100b70:	c3                   	ret    

f0100b71 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100b71:	f3 0f 1e fb          	endbr32 
f0100b75:	55                   	push   %ebp
f0100b76:	89 e5                	mov    %esp,%ebp
f0100b78:	53                   	push   %ebx
f0100b79:	83 ec 14             	sub    $0x14,%esp
f0100b7c:	e8 4b f6 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100b81:	81 c3 87 07 01 00    	add    $0x10787,%ebx
	int cnt = 0;
f0100b87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b8e:	ff 75 0c             	pushl  0xc(%ebp)
f0100b91:	ff 75 08             	pushl  0x8(%ebp)
f0100b94:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b97:	50                   	push   %eax
f0100b98:	8d 83 43 f8 fe ff    	lea    -0x107bd(%ebx),%eax
f0100b9e:	50                   	push   %eax
f0100b9f:	e8 57 04 00 00       	call   f0100ffb <vprintfmt>
	return cnt;
}
f0100ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ba7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100baa:	c9                   	leave  
f0100bab:	c3                   	ret    

f0100bac <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100bac:	f3 0f 1e fb          	endbr32 
f0100bb0:	55                   	push   %ebp
f0100bb1:	89 e5                	mov    %esp,%ebp
f0100bb3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100bb6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100bb9:	50                   	push   %eax
f0100bba:	ff 75 08             	pushl  0x8(%ebp)
f0100bbd:	e8 af ff ff ff       	call   f0100b71 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100bc2:	c9                   	leave  
f0100bc3:	c3                   	ret    

f0100bc4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100bc4:	55                   	push   %ebp
f0100bc5:	89 e5                	mov    %esp,%ebp
f0100bc7:	57                   	push   %edi
f0100bc8:	56                   	push   %esi
f0100bc9:	53                   	push   %ebx
f0100bca:	83 ec 14             	sub    $0x14,%esp
f0100bcd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100bd0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100bd3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100bd6:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100bd9:	8b 1a                	mov    (%edx),%ebx
f0100bdb:	8b 01                	mov    (%ecx),%eax
f0100bdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100be0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100be7:	eb 23                	jmp    f0100c0c <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100be9:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100bec:	eb 1e                	jmp    f0100c0c <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100bee:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bf1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100bf4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100bf8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bfb:	73 46                	jae    f0100c43 <stab_binsearch+0x7f>
			*region_left = m;
f0100bfd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100c00:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100c02:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100c05:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100c0c:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100c0f:	7f 5f                	jg     f0100c70 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100c14:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100c17:	89 d0                	mov    %edx,%eax
f0100c19:	c1 e8 1f             	shr    $0x1f,%eax
f0100c1c:	01 d0                	add    %edx,%eax
f0100c1e:	89 c7                	mov    %eax,%edi
f0100c20:	d1 ff                	sar    %edi
f0100c22:	83 e0 fe             	and    $0xfffffffe,%eax
f0100c25:	01 f8                	add    %edi,%eax
f0100c27:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100c2a:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100c2e:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100c30:	39 c3                	cmp    %eax,%ebx
f0100c32:	7f b5                	jg     f0100be9 <stab_binsearch+0x25>
f0100c34:	0f b6 0a             	movzbl (%edx),%ecx
f0100c37:	83 ea 0c             	sub    $0xc,%edx
f0100c3a:	39 f1                	cmp    %esi,%ecx
f0100c3c:	74 b0                	je     f0100bee <stab_binsearch+0x2a>
			m--;
f0100c3e:	83 e8 01             	sub    $0x1,%eax
f0100c41:	eb ed                	jmp    f0100c30 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0100c43:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c46:	76 14                	jbe    f0100c5c <stab_binsearch+0x98>
			*region_right = m - 1;
f0100c48:	83 e8 01             	sub    $0x1,%eax
f0100c4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c4e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c51:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100c53:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c5a:	eb b0                	jmp    f0100c0c <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100c5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c5f:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100c61:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100c65:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100c67:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c6e:	eb 9c                	jmp    f0100c0c <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0100c70:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100c74:	75 15                	jne    f0100c8b <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100c76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c79:	8b 00                	mov    (%eax),%eax
f0100c7b:	83 e8 01             	sub    $0x1,%eax
f0100c7e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c81:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100c83:	83 c4 14             	add    $0x14,%esp
f0100c86:	5b                   	pop    %ebx
f0100c87:	5e                   	pop    %esi
f0100c88:	5f                   	pop    %edi
f0100c89:	5d                   	pop    %ebp
f0100c8a:	c3                   	ret    
		for (l = *region_right;
f0100c8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c8e:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c93:	8b 0f                	mov    (%edi),%ecx
f0100c95:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c98:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100c9b:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100c9f:	eb 03                	jmp    f0100ca4 <stab_binsearch+0xe0>
		     l--)
f0100ca1:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100ca4:	39 c1                	cmp    %eax,%ecx
f0100ca6:	7d 0a                	jge    f0100cb2 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0100ca8:	0f b6 1a             	movzbl (%edx),%ebx
f0100cab:	83 ea 0c             	sub    $0xc,%edx
f0100cae:	39 f3                	cmp    %esi,%ebx
f0100cb0:	75 ef                	jne    f0100ca1 <stab_binsearch+0xdd>
		*region_left = l;
f0100cb2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100cb5:	89 07                	mov    %eax,(%edi)
}
f0100cb7:	eb ca                	jmp    f0100c83 <stab_binsearch+0xbf>

f0100cb9 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100cb9:	f3 0f 1e fb          	endbr32 
f0100cbd:	55                   	push   %ebp
f0100cbe:	89 e5                	mov    %esp,%ebp
f0100cc0:	57                   	push   %edi
f0100cc1:	56                   	push   %esi
f0100cc2:	53                   	push   %ebx
f0100cc3:	83 ec 3c             	sub    $0x3c,%esp
f0100cc6:	e8 01 f5 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100ccb:	81 c3 3d 06 01 00    	add    $0x1063d,%ebx
f0100cd1:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100cd4:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100cd7:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100cda:	8d 83 dd 0b ff ff    	lea    -0xf423(%ebx),%eax
f0100ce0:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100ce2:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100ce9:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100cec:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100cf3:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100cf6:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100cfd:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100d03:	0f 86 38 01 00 00    	jbe    f0100e41 <debuginfo_eip+0x188>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100d09:	c7 c0 41 65 10 f0    	mov    $0xf0106541,%eax
f0100d0f:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100d15:	0f 86 da 01 00 00    	jbe    f0100ef5 <debuginfo_eip+0x23c>
f0100d1b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d1e:	c7 c0 07 7f 10 f0    	mov    $0xf0107f07,%eax
f0100d24:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100d28:	0f 85 ce 01 00 00    	jne    f0100efc <debuginfo_eip+0x243>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100d2e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100d35:	c7 c0 00 21 10 f0    	mov    $0xf0102100,%eax
f0100d3b:	c7 c2 40 65 10 f0    	mov    $0xf0106540,%edx
f0100d41:	29 c2                	sub    %eax,%edx
f0100d43:	c1 fa 02             	sar    $0x2,%edx
f0100d46:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100d4c:	83 ea 01             	sub    $0x1,%edx
f0100d4f:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100d52:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100d55:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100d58:	83 ec 08             	sub    $0x8,%esp
f0100d5b:	57                   	push   %edi
f0100d5c:	6a 64                	push   $0x64
f0100d5e:	e8 61 fe ff ff       	call   f0100bc4 <stab_binsearch>
	if (lfile == 0)
f0100d63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d66:	83 c4 10             	add    $0x10,%esp
f0100d69:	85 c0                	test   %eax,%eax
f0100d6b:	0f 84 92 01 00 00    	je     f0100f03 <debuginfo_eip+0x24a>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d71:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100d74:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d77:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d7a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d7d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d80:	83 ec 08             	sub    $0x8,%esp
f0100d83:	57                   	push   %edi
f0100d84:	6a 24                	push   $0x24
f0100d86:	c7 c0 00 21 10 f0    	mov    $0xf0102100,%eax
f0100d8c:	e8 33 fe ff ff       	call   f0100bc4 <stab_binsearch>

	if (lfun <= rfun) {
f0100d91:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d94:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100d97:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0100d9a:	83 c4 10             	add    $0x10,%esp
f0100d9d:	39 c8                	cmp    %ecx,%eax
f0100d9f:	0f 8f b7 00 00 00    	jg     f0100e5c <debuginfo_eip+0x1a3>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100da5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100da8:	c7 c1 00 21 10 f0    	mov    $0xf0102100,%ecx
f0100dae:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100db1:	8b 11                	mov    (%ecx),%edx
f0100db3:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0100db6:	c7 c2 07 7f 10 f0    	mov    $0xf0107f07,%edx
f0100dbc:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100dbf:	81 ea 41 65 10 f0    	sub    $0xf0106541,%edx
f0100dc5:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0100dc8:	39 d3                	cmp    %edx,%ebx
f0100dca:	73 0c                	jae    f0100dd8 <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100dcc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100dcf:	81 c3 41 65 10 f0    	add    $0xf0106541,%ebx
f0100dd5:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100dd8:	8b 51 08             	mov    0x8(%ecx),%edx
f0100ddb:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100dde:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100de0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100de3:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100de6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100de9:	83 ec 08             	sub    $0x8,%esp
f0100dec:	6a 3a                	push   $0x3a
f0100dee:	ff 76 08             	pushl  0x8(%esi)
f0100df1:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100df4:	e8 96 09 00 00       	call   f010178f <strfind>
f0100df9:	2b 46 08             	sub    0x8(%esi),%eax
f0100dfc:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100dff:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100e02:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100e05:	83 c4 08             	add    $0x8,%esp
f0100e08:	57                   	push   %edi
f0100e09:	6a 44                	push   $0x44
f0100e0b:	c7 c0 00 21 10 f0    	mov    $0xf0102100,%eax
f0100e11:	e8 ae fd ff ff       	call   f0100bc4 <stab_binsearch>
	if(lline <= rline)
f0100e16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e19:	83 c4 10             	add    $0x10,%esp
f0100e1c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100e1f:	0f 8f e5 00 00 00    	jg     f0100f0a <debuginfo_eip+0x251>
		info -> eip_line = stabs[lline].n_desc;
f0100e25:	89 c2                	mov    %eax,%edx
f0100e27:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100e2a:	c7 c0 00 21 10 f0    	mov    $0xf0102100,%eax
f0100e30:	0f b7 5c 88 06       	movzwl 0x6(%eax,%ecx,4),%ebx
f0100e35:	89 5e 04             	mov    %ebx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e3b:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0100e3f:	eb 35                	jmp    f0100e76 <debuginfo_eip+0x1bd>
  	        panic("User address");
f0100e41:	83 ec 04             	sub    $0x4,%esp
f0100e44:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e47:	8d 83 e7 0b ff ff    	lea    -0xf419(%ebx),%eax
f0100e4d:	50                   	push   %eax
f0100e4e:	6a 7f                	push   $0x7f
f0100e50:	8d 83 f4 0b ff ff    	lea    -0xf40c(%ebx),%eax
f0100e56:	50                   	push   %eax
f0100e57:	e8 b2 f2 ff ff       	call   f010010e <_panic>
		info->eip_fn_addr = addr;
f0100e5c:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100e5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e62:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100e65:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e68:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e6b:	e9 79 ff ff ff       	jmp    f0100de9 <debuginfo_eip+0x130>
f0100e70:	83 ea 01             	sub    $0x1,%edx
f0100e73:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100e76:	39 d7                	cmp    %edx,%edi
f0100e78:	7f 3a                	jg     f0100eb4 <debuginfo_eip+0x1fb>
	       && stabs[lline].n_type != N_SOL
f0100e7a:	0f b6 08             	movzbl (%eax),%ecx
f0100e7d:	80 f9 84             	cmp    $0x84,%cl
f0100e80:	74 0b                	je     f0100e8d <debuginfo_eip+0x1d4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e82:	80 f9 64             	cmp    $0x64,%cl
f0100e85:	75 e9                	jne    f0100e70 <debuginfo_eip+0x1b7>
f0100e87:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100e8b:	74 e3                	je     f0100e70 <debuginfo_eip+0x1b7>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e8d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100e90:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100e93:	c7 c0 00 21 10 f0    	mov    $0xf0102100,%eax
f0100e99:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e9c:	c7 c0 07 7f 10 f0    	mov    $0xf0107f07,%eax
f0100ea2:	81 e8 41 65 10 f0    	sub    $0xf0106541,%eax
f0100ea8:	39 c2                	cmp    %eax,%edx
f0100eaa:	73 08                	jae    f0100eb4 <debuginfo_eip+0x1fb>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100eac:	81 c2 41 65 10 f0    	add    $0xf0106541,%edx
f0100eb2:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100eb4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100eb7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100eba:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100ebf:	39 da                	cmp    %ebx,%edx
f0100ec1:	7d 53                	jge    f0100f16 <debuginfo_eip+0x25d>
		for (lline = lfun + 1;
f0100ec3:	8d 42 01             	lea    0x1(%edx),%eax
f0100ec6:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100ec9:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ecc:	c7 c2 00 21 10 f0    	mov    $0xf0102100,%edx
f0100ed2:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100ed6:	eb 04                	jmp    f0100edc <debuginfo_eip+0x223>
			info->eip_fn_narg++;
f0100ed8:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100edc:	39 c3                	cmp    %eax,%ebx
f0100ede:	7e 31                	jle    f0100f11 <debuginfo_eip+0x258>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ee0:	0f b6 0a             	movzbl (%edx),%ecx
f0100ee3:	83 c0 01             	add    $0x1,%eax
f0100ee6:	83 c2 0c             	add    $0xc,%edx
f0100ee9:	80 f9 a0             	cmp    $0xa0,%cl
f0100eec:	74 ea                	je     f0100ed8 <debuginfo_eip+0x21f>
	return 0;
f0100eee:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ef3:	eb 21                	jmp    f0100f16 <debuginfo_eip+0x25d>
		return -1;
f0100ef5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100efa:	eb 1a                	jmp    f0100f16 <debuginfo_eip+0x25d>
f0100efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f01:	eb 13                	jmp    f0100f16 <debuginfo_eip+0x25d>
		return -1;
f0100f03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f08:	eb 0c                	jmp    f0100f16 <debuginfo_eip+0x25d>
		return -1;
f0100f0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f0f:	eb 05                	jmp    f0100f16 <debuginfo_eip+0x25d>
	return 0;
f0100f11:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f16:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f19:	5b                   	pop    %ebx
f0100f1a:	5e                   	pop    %esi
f0100f1b:	5f                   	pop    %edi
f0100f1c:	5d                   	pop    %ebp
f0100f1d:	c3                   	ret    

f0100f1e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100f1e:	55                   	push   %ebp
f0100f1f:	89 e5                	mov    %esp,%ebp
f0100f21:	57                   	push   %edi
f0100f22:	56                   	push   %esi
f0100f23:	53                   	push   %ebx
f0100f24:	83 ec 1c             	sub    $0x1c,%esp
f0100f27:	e8 c9 05 00 00       	call   f01014f5 <__x86.get_pc_thunk.cx>
f0100f2c:	81 c1 dc 03 01 00    	add    $0x103dc,%ecx
f0100f32:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100f35:	89 c6                	mov    %eax,%esi
f0100f37:	89 d7                	mov    %edx,%edi
f0100f39:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f3f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100f42:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f47:	3b 45 10             	cmp    0x10(%ebp),%eax
f0100f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f4d:	19 c8                	sbb    %ecx,%eax
f0100f4f:	72 39                	jb     f0100f8a <printnum+0x6c>
		
		printnum(putch, putdat, ((unsigned long)num)/base, base, width - 1, padc);
f0100f51:	83 ec 0c             	sub    $0xc,%esp
f0100f54:	ff 75 18             	pushl  0x18(%ebp)
f0100f57:	83 eb 01             	sub    $0x1,%ebx
f0100f5a:	53                   	push   %ebx
f0100f5b:	ff 75 10             	pushl  0x10(%ebp)
f0100f5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f61:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f66:	f7 75 10             	divl   0x10(%ebp)
f0100f69:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f6e:	52                   	push   %edx
f0100f6f:	50                   	push   %eax
f0100f70:	89 fa                	mov    %edi,%edx
f0100f72:	89 f0                	mov    %esi,%eax
f0100f74:	e8 a5 ff ff ff       	call   f0100f1e <printnum>
f0100f79:	83 c4 20             	add    $0x20,%esp
f0100f7c:	eb 13                	jmp    f0100f91 <printnum+0x73>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f7e:	83 ec 08             	sub    $0x8,%esp
f0100f81:	57                   	push   %edi
f0100f82:	ff 75 18             	pushl  0x18(%ebp)
f0100f85:	ff d6                	call   *%esi
f0100f87:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f8a:	83 eb 01             	sub    $0x1,%ebx
f0100f8d:	85 db                	test   %ebx,%ebx
f0100f8f:	7f ed                	jg     f0100f7e <printnum+0x60>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[((unsigned long)num) % base], putdat);
f0100f91:	83 ec 08             	sub    $0x8,%esp
f0100f94:	57                   	push   %edi
f0100f95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f98:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f9d:	f7 75 10             	divl   0x10(%ebp)
f0100fa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fa3:	0f be 84 10 02 0c ff 	movsbl -0xf3fe(%eax,%edx,1),%eax
f0100faa:	ff 
f0100fab:	50                   	push   %eax
f0100fac:	ff d6                	call   *%esi
}
f0100fae:	83 c4 10             	add    $0x10,%esp
f0100fb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fb4:	5b                   	pop    %ebx
f0100fb5:	5e                   	pop    %esi
f0100fb6:	5f                   	pop    %edi
f0100fb7:	5d                   	pop    %ebp
f0100fb8:	c3                   	ret    

f0100fb9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100fb9:	f3 0f 1e fb          	endbr32 
f0100fbd:	55                   	push   %ebp
f0100fbe:	89 e5                	mov    %esp,%ebp
f0100fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100fc3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100fc7:	8b 10                	mov    (%eax),%edx
f0100fc9:	3b 50 04             	cmp    0x4(%eax),%edx
f0100fcc:	73 0a                	jae    f0100fd8 <sprintputch+0x1f>
		*b->buf++ = ch;
f0100fce:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100fd1:	89 08                	mov    %ecx,(%eax)
f0100fd3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fd6:	88 02                	mov    %al,(%edx)
}
f0100fd8:	5d                   	pop    %ebp
f0100fd9:	c3                   	ret    

f0100fda <printfmt>:
{
f0100fda:	f3 0f 1e fb          	endbr32 
f0100fde:	55                   	push   %ebp
f0100fdf:	89 e5                	mov    %esp,%ebp
f0100fe1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100fe4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100fe7:	50                   	push   %eax
f0100fe8:	ff 75 10             	pushl  0x10(%ebp)
f0100feb:	ff 75 0c             	pushl  0xc(%ebp)
f0100fee:	ff 75 08             	pushl  0x8(%ebp)
f0100ff1:	e8 05 00 00 00       	call   f0100ffb <vprintfmt>
}
f0100ff6:	83 c4 10             	add    $0x10,%esp
f0100ff9:	c9                   	leave  
f0100ffa:	c3                   	ret    

f0100ffb <vprintfmt>:
{
f0100ffb:	f3 0f 1e fb          	endbr32 
f0100fff:	55                   	push   %ebp
f0101000:	89 e5                	mov    %esp,%ebp
f0101002:	57                   	push   %edi
f0101003:	56                   	push   %esi
f0101004:	53                   	push   %ebx
f0101005:	83 ec 3c             	sub    $0x3c,%esp
f0101008:	e8 73 f7 ff ff       	call   f0100780 <__x86.get_pc_thunk.ax>
f010100d:	05 fb 02 01 00       	add    $0x102fb,%eax
f0101012:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101015:	8b 75 08             	mov    0x8(%ebp),%esi
f0101018:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010101b:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010101e:	8d 80 3c 1d 00 00    	lea    0x1d3c(%eax),%eax
f0101024:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101027:	e9 91 03 00 00       	jmp    f01013bd <.L25+0x48>
		padc = ' ';
f010102c:	c6 45 cb 20          	movb   $0x20,-0x35(%ebp)
		altflag = 0;
f0101030:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0101037:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010103e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f0101045:	b9 00 00 00 00       	mov    $0x0,%ecx
f010104a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010104d:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101050:	8d 43 01             	lea    0x1(%ebx),%eax
f0101053:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101056:	0f b6 13             	movzbl (%ebx),%edx
f0101059:	8d 42 dd             	lea    -0x23(%edx),%eax
f010105c:	3c 55                	cmp    $0x55,%al
f010105e:	0f 87 e5 03 00 00    	ja     f0101449 <.L20>
f0101064:	0f b6 c0             	movzbl %al,%eax
f0101067:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010106a:	89 ce                	mov    %ecx,%esi
f010106c:	03 b4 81 90 0c ff ff 	add    -0xf370(%ecx,%eax,4),%esi
f0101073:	3e ff e6             	notrack jmp *%esi

f0101076 <.L66>:
f0101076:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0101079:	c6 45 cb 2d          	movb   $0x2d,-0x35(%ebp)
f010107d:	eb d1                	jmp    f0101050 <vprintfmt+0x55>

f010107f <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f010107f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101082:	c6 45 cb 30          	movb   $0x30,-0x35(%ebp)
f0101086:	eb c8                	jmp    f0101050 <vprintfmt+0x55>

f0101088 <.L31>:
f0101088:	0f b6 d2             	movzbl %dl,%edx
f010108b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f010108e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101093:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0101096:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101099:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010109d:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01010a0:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01010a3:	83 f9 09             	cmp    $0x9,%ecx
f01010a6:	77 4c                	ja     f01010f4 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01010a8:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01010ab:	eb e9                	jmp    f0101096 <.L31+0xe>

f01010ad <.L34>:
			precision = va_arg(ap, int);
f01010ad:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b0:	8b 00                	mov    (%eax),%eax
f01010b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b8:	8d 40 04             	lea    0x4(%eax),%eax
f01010bb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010be:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01010c1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01010c5:	78 35                	js     f01010fc <.L36+0x17>
			lflag++;
f01010c7:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
			goto reswitch;
f01010cb:	eb 83                	jmp    f0101050 <vprintfmt+0x55>

f01010cd <.L33>:
f01010cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01010d0:	85 c0                	test   %eax,%eax
f01010d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01010d7:	0f 49 d0             	cmovns %eax,%edx
f01010da:	89 55 d0             	mov    %edx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010dd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01010e0:	e9 6b ff ff ff       	jmp    f0101050 <vprintfmt+0x55>

f01010e5 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f01010e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f01010e8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01010ef:	e9 5c ff ff ff       	jmp    f0101050 <vprintfmt+0x55>
f01010f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010f7:	89 75 08             	mov    %esi,0x8(%ebp)
f01010fa:	eb c5                	jmp    f01010c1 <.L34+0x14>
				width = precision, precision = -1;
f01010fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101102:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0101109:	eb bc                	jmp    f01010c7 <.L34+0x1a>

f010110b <.L67>:
		switch (ch = *(unsigned char *) fmt++) {
f010110b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010110e:	eb b7                	jmp    f01010c7 <.L34+0x1a>

f0101110 <.L30>:
f0101110:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f0101113:	8b 45 14             	mov    0x14(%ebp),%eax
f0101116:	8d 58 04             	lea    0x4(%eax),%ebx
f0101119:	83 ec 08             	sub    $0x8,%esp
f010111c:	57                   	push   %edi
f010111d:	ff 30                	pushl  (%eax)
f010111f:	ff d6                	call   *%esi
			break;
f0101121:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101124:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0101127:	e9 8e 02 00 00       	jmp    f01013ba <.L25+0x45>

f010112c <.L28>:
f010112c:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f010112f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101132:	8d 58 04             	lea    0x4(%eax),%ebx
f0101135:	8b 00                	mov    (%eax),%eax
f0101137:	99                   	cltd   
f0101138:	31 d0                	xor    %edx,%eax
f010113a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010113c:	83 f8 06             	cmp    $0x6,%eax
f010113f:	7f 27                	jg     f0101168 <.L28+0x3c>
f0101141:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101144:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0101147:	85 d2                	test   %edx,%edx
f0101149:	74 1d                	je     f0101168 <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f010114b:	52                   	push   %edx
f010114c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010114f:	8d 80 23 0c ff ff    	lea    -0xf3dd(%eax),%eax
f0101155:	50                   	push   %eax
f0101156:	57                   	push   %edi
f0101157:	56                   	push   %esi
f0101158:	e8 7d fe ff ff       	call   f0100fda <printfmt>
f010115d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101160:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0101163:	e9 52 02 00 00       	jmp    f01013ba <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0101168:	50                   	push   %eax
f0101169:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010116c:	8d 80 1a 0c ff ff    	lea    -0xf3e6(%eax),%eax
f0101172:	50                   	push   %eax
f0101173:	57                   	push   %edi
f0101174:	56                   	push   %esi
f0101175:	e8 60 fe ff ff       	call   f0100fda <printfmt>
f010117a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010117d:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101180:	e9 35 02 00 00       	jmp    f01013ba <.L25+0x45>

f0101185 <.L24>:
f0101185:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f0101188:	8b 45 14             	mov    0x14(%ebp),%eax
f010118b:	83 c0 04             	add    $0x4,%eax
f010118e:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0101191:	8b 45 14             	mov    0x14(%ebp),%eax
f0101194:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0101196:	85 d2                	test   %edx,%edx
f0101198:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010119b:	8d 80 13 0c ff ff    	lea    -0xf3ed(%eax),%eax
f01011a1:	0f 45 c2             	cmovne %edx,%eax
f01011a4:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f01011a7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01011ab:	7e 06                	jle    f01011b3 <.L24+0x2e>
f01011ad:	80 7d cb 2d          	cmpb   $0x2d,-0x35(%ebp)
f01011b1:	75 0d                	jne    f01011c0 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01011b3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01011b6:	89 c3                	mov    %eax,%ebx
f01011b8:	03 45 d0             	add    -0x30(%ebp),%eax
f01011bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01011be:	eb 58                	jmp    f0101218 <.L24+0x93>
f01011c0:	83 ec 08             	sub    $0x8,%esp
f01011c3:	ff 75 d8             	pushl  -0x28(%ebp)
f01011c6:	ff 75 cc             	pushl  -0x34(%ebp)
f01011c9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01011cc:	e8 4d 04 00 00       	call   f010161e <strnlen>
f01011d1:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01011d4:	29 c2                	sub    %eax,%edx
f01011d6:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01011d9:	83 c4 10             	add    $0x10,%esp
f01011dc:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01011de:	0f be 45 cb          	movsbl -0x35(%ebp),%eax
f01011e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01011e5:	85 db                	test   %ebx,%ebx
f01011e7:	7e 11                	jle    f01011fa <.L24+0x75>
					putch(padc, putdat);
f01011e9:	83 ec 08             	sub    $0x8,%esp
f01011ec:	57                   	push   %edi
f01011ed:	ff 75 d0             	pushl  -0x30(%ebp)
f01011f0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01011f2:	83 eb 01             	sub    $0x1,%ebx
f01011f5:	83 c4 10             	add    $0x10,%esp
f01011f8:	eb eb                	jmp    f01011e5 <.L24+0x60>
f01011fa:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01011fd:	85 d2                	test   %edx,%edx
f01011ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0101204:	0f 49 c2             	cmovns %edx,%eax
f0101207:	29 c2                	sub    %eax,%edx
f0101209:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010120c:	eb a5                	jmp    f01011b3 <.L24+0x2e>
					putch(ch, putdat);
f010120e:	83 ec 08             	sub    $0x8,%esp
f0101211:	57                   	push   %edi
f0101212:	52                   	push   %edx
f0101213:	ff d6                	call   *%esi
f0101215:	83 c4 10             	add    $0x10,%esp
f0101218:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010121b:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010121d:	83 c3 01             	add    $0x1,%ebx
f0101220:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101224:	0f be d0             	movsbl %al,%edx
f0101227:	85 d2                	test   %edx,%edx
f0101229:	74 4b                	je     f0101276 <.L24+0xf1>
f010122b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010122f:	78 06                	js     f0101237 <.L24+0xb2>
f0101231:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101235:	78 1e                	js     f0101255 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0101237:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010123b:	74 d1                	je     f010120e <.L24+0x89>
f010123d:	0f be c0             	movsbl %al,%eax
f0101240:	83 e8 20             	sub    $0x20,%eax
f0101243:	83 f8 5e             	cmp    $0x5e,%eax
f0101246:	76 c6                	jbe    f010120e <.L24+0x89>
					putch('?', putdat);
f0101248:	83 ec 08             	sub    $0x8,%esp
f010124b:	57                   	push   %edi
f010124c:	6a 3f                	push   $0x3f
f010124e:	ff d6                	call   *%esi
f0101250:	83 c4 10             	add    $0x10,%esp
f0101253:	eb c3                	jmp    f0101218 <.L24+0x93>
f0101255:	89 cb                	mov    %ecx,%ebx
f0101257:	eb 0e                	jmp    f0101267 <.L24+0xe2>
				putch(' ', putdat);
f0101259:	83 ec 08             	sub    $0x8,%esp
f010125c:	57                   	push   %edi
f010125d:	6a 20                	push   $0x20
f010125f:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0101261:	83 eb 01             	sub    $0x1,%ebx
f0101264:	83 c4 10             	add    $0x10,%esp
f0101267:	85 db                	test   %ebx,%ebx
f0101269:	7f ee                	jg     f0101259 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f010126b:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010126e:	89 45 14             	mov    %eax,0x14(%ebp)
f0101271:	e9 44 01 00 00       	jmp    f01013ba <.L25+0x45>
f0101276:	89 cb                	mov    %ecx,%ebx
f0101278:	eb ed                	jmp    f0101267 <.L24+0xe2>

f010127a <.L29>:
f010127a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010127d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101280:	83 f9 01             	cmp    $0x1,%ecx
f0101283:	7f 1b                	jg     f01012a0 <.L29+0x26>
	else if (lflag)
f0101285:	85 c9                	test   %ecx,%ecx
f0101287:	74 63                	je     f01012ec <.L29+0x72>
		return va_arg(*ap, long);
f0101289:	8b 45 14             	mov    0x14(%ebp),%eax
f010128c:	8b 00                	mov    (%eax),%eax
f010128e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101291:	99                   	cltd   
f0101292:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101295:	8b 45 14             	mov    0x14(%ebp),%eax
f0101298:	8d 40 04             	lea    0x4(%eax),%eax
f010129b:	89 45 14             	mov    %eax,0x14(%ebp)
f010129e:	eb 17                	jmp    f01012b7 <.L29+0x3d>
		return va_arg(*ap, long long);
f01012a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01012a3:	8b 50 04             	mov    0x4(%eax),%edx
f01012a6:	8b 00                	mov    (%eax),%eax
f01012a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012ae:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b1:	8d 40 08             	lea    0x8(%eax),%eax
f01012b4:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01012b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01012bd:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01012c2:	85 c9                	test   %ecx,%ecx
f01012c4:	0f 89 d6 00 00 00    	jns    f01013a0 <.L25+0x2b>
				putch('-', putdat);
f01012ca:	83 ec 08             	sub    $0x8,%esp
f01012cd:	57                   	push   %edi
f01012ce:	6a 2d                	push   $0x2d
f01012d0:	ff d6                	call   *%esi
				num = -(long long) num;
f01012d2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012d5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01012d8:	f7 da                	neg    %edx
f01012da:	83 d1 00             	adc    $0x0,%ecx
f01012dd:	f7 d9                	neg    %ecx
f01012df:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01012e2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012e7:	e9 b4 00 00 00       	jmp    f01013a0 <.L25+0x2b>
		return va_arg(*ap, int);
f01012ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ef:	8b 00                	mov    (%eax),%eax
f01012f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012f4:	99                   	cltd   
f01012f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01012fb:	8d 40 04             	lea    0x4(%eax),%eax
f01012fe:	89 45 14             	mov    %eax,0x14(%ebp)
f0101301:	eb b4                	jmp    f01012b7 <.L29+0x3d>

f0101303 <.L23>:
f0101303:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101306:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101309:	83 f9 01             	cmp    $0x1,%ecx
f010130c:	7f 1b                	jg     f0101329 <.L23+0x26>
	else if (lflag)
f010130e:	85 c9                	test   %ecx,%ecx
f0101310:	74 2c                	je     f010133e <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f0101312:	8b 45 14             	mov    0x14(%ebp),%eax
f0101315:	8b 10                	mov    (%eax),%edx
f0101317:	b9 00 00 00 00       	mov    $0x0,%ecx
f010131c:	8d 40 04             	lea    0x4(%eax),%eax
f010131f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101322:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f0101327:	eb 77                	jmp    f01013a0 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101329:	8b 45 14             	mov    0x14(%ebp),%eax
f010132c:	8b 10                	mov    (%eax),%edx
f010132e:	8b 48 04             	mov    0x4(%eax),%ecx
f0101331:	8d 40 08             	lea    0x8(%eax),%eax
f0101334:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101337:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f010133c:	eb 62                	jmp    f01013a0 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f010133e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101341:	8b 10                	mov    (%eax),%edx
f0101343:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101348:	8d 40 04             	lea    0x4(%eax),%eax
f010134b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010134e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0101353:	eb 4b                	jmp    f01013a0 <.L25+0x2b>

f0101355 <.L26>:
f0101355:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('X', putdat);
f0101358:	83 ec 08             	sub    $0x8,%esp
f010135b:	57                   	push   %edi
f010135c:	6a 58                	push   $0x58
f010135e:	ff d6                	call   *%esi
			putch('X', putdat);
f0101360:	83 c4 08             	add    $0x8,%esp
f0101363:	57                   	push   %edi
f0101364:	6a 58                	push   $0x58
f0101366:	ff d6                	call   *%esi
			putch('X', putdat);
f0101368:	83 c4 08             	add    $0x8,%esp
f010136b:	57                   	push   %edi
f010136c:	6a 58                	push   $0x58
f010136e:	ff d6                	call   *%esi
			break;
f0101370:	83 c4 10             	add    $0x10,%esp
f0101373:	eb 45                	jmp    f01013ba <.L25+0x45>

f0101375 <.L25>:
f0101375:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f0101378:	83 ec 08             	sub    $0x8,%esp
f010137b:	57                   	push   %edi
f010137c:	6a 30                	push   $0x30
f010137e:	ff d6                	call   *%esi
			putch('x', putdat);
f0101380:	83 c4 08             	add    $0x8,%esp
f0101383:	57                   	push   %edi
f0101384:	6a 78                	push   $0x78
f0101386:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101388:	8b 45 14             	mov    0x14(%ebp),%eax
f010138b:	8b 10                	mov    (%eax),%edx
f010138d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0101392:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101395:	8d 40 04             	lea    0x4(%eax),%eax
f0101398:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010139b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01013a0:	83 ec 0c             	sub    $0xc,%esp
f01013a3:	0f be 5d cb          	movsbl -0x35(%ebp),%ebx
f01013a7:	53                   	push   %ebx
f01013a8:	ff 75 d0             	pushl  -0x30(%ebp)
f01013ab:	50                   	push   %eax
f01013ac:	51                   	push   %ecx
f01013ad:	52                   	push   %edx
f01013ae:	89 fa                	mov    %edi,%edx
f01013b0:	89 f0                	mov    %esi,%eax
f01013b2:	e8 67 fb ff ff       	call   f0100f1e <printnum>
			break;
f01013b7:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f01013ba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01013bd:	83 c3 01             	add    $0x1,%ebx
f01013c0:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01013c4:	83 f8 25             	cmp    $0x25,%eax
f01013c7:	0f 84 5f fc ff ff    	je     f010102c <vprintfmt+0x31>
			if (ch == '\0')
f01013cd:	85 c0                	test   %eax,%eax
f01013cf:	0f 84 97 00 00 00    	je     f010146c <.L20+0x23>
			putch(ch, putdat);
f01013d5:	83 ec 08             	sub    $0x8,%esp
f01013d8:	57                   	push   %edi
f01013d9:	50                   	push   %eax
f01013da:	ff d6                	call   *%esi
f01013dc:	83 c4 10             	add    $0x10,%esp
f01013df:	eb dc                	jmp    f01013bd <.L25+0x48>

f01013e1 <.L21>:
f01013e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01013e4:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01013e7:	83 f9 01             	cmp    $0x1,%ecx
f01013ea:	7f 1b                	jg     f0101407 <.L21+0x26>
	else if (lflag)
f01013ec:	85 c9                	test   %ecx,%ecx
f01013ee:	74 2c                	je     f010141c <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f01013f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01013f3:	8b 10                	mov    (%eax),%edx
f01013f5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013fa:	8d 40 04             	lea    0x4(%eax),%eax
f01013fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101400:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0101405:	eb 99                	jmp    f01013a0 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101407:	8b 45 14             	mov    0x14(%ebp),%eax
f010140a:	8b 10                	mov    (%eax),%edx
f010140c:	8b 48 04             	mov    0x4(%eax),%ecx
f010140f:	8d 40 08             	lea    0x8(%eax),%eax
f0101412:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101415:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f010141a:	eb 84                	jmp    f01013a0 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f010141c:	8b 45 14             	mov    0x14(%ebp),%eax
f010141f:	8b 10                	mov    (%eax),%edx
f0101421:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101426:	8d 40 04             	lea    0x4(%eax),%eax
f0101429:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010142c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0101431:	e9 6a ff ff ff       	jmp    f01013a0 <.L25+0x2b>

f0101436 <.L35>:
f0101436:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f0101439:	83 ec 08             	sub    $0x8,%esp
f010143c:	57                   	push   %edi
f010143d:	6a 25                	push   $0x25
f010143f:	ff d6                	call   *%esi
			break;
f0101441:	83 c4 10             	add    $0x10,%esp
f0101444:	e9 71 ff ff ff       	jmp    f01013ba <.L25+0x45>

f0101449 <.L20>:
f0101449:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f010144c:	83 ec 08             	sub    $0x8,%esp
f010144f:	57                   	push   %edi
f0101450:	6a 25                	push   $0x25
f0101452:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101454:	83 c4 10             	add    $0x10,%esp
f0101457:	89 d8                	mov    %ebx,%eax
f0101459:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010145d:	74 05                	je     f0101464 <.L20+0x1b>
f010145f:	83 e8 01             	sub    $0x1,%eax
f0101462:	eb f5                	jmp    f0101459 <.L20+0x10>
f0101464:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101467:	e9 4e ff ff ff       	jmp    f01013ba <.L25+0x45>
}
f010146c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010146f:	5b                   	pop    %ebx
f0101470:	5e                   	pop    %esi
f0101471:	5f                   	pop    %edi
f0101472:	5d                   	pop    %ebp
f0101473:	c3                   	ret    

f0101474 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101474:	f3 0f 1e fb          	endbr32 
f0101478:	55                   	push   %ebp
f0101479:	89 e5                	mov    %esp,%ebp
f010147b:	53                   	push   %ebx
f010147c:	83 ec 14             	sub    $0x14,%esp
f010147f:	e8 48 ed ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0101484:	81 c3 84 fe 00 00    	add    $0xfe84,%ebx
f010148a:	8b 45 08             	mov    0x8(%ebp),%eax
f010148d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101490:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101493:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101497:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010149a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01014a1:	85 c0                	test   %eax,%eax
f01014a3:	74 2b                	je     f01014d0 <vsnprintf+0x5c>
f01014a5:	85 d2                	test   %edx,%edx
f01014a7:	7e 27                	jle    f01014d0 <vsnprintf+0x5c>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01014a9:	ff 75 14             	pushl  0x14(%ebp)
f01014ac:	ff 75 10             	pushl  0x10(%ebp)
f01014af:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01014b2:	50                   	push   %eax
f01014b3:	8d 83 b1 fc fe ff    	lea    -0x1034f(%ebx),%eax
f01014b9:	50                   	push   %eax
f01014ba:	e8 3c fb ff ff       	call   f0100ffb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01014bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01014c2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01014c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01014c8:	83 c4 10             	add    $0x10,%esp
}
f01014cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014ce:	c9                   	leave  
f01014cf:	c3                   	ret    
		return -E_INVAL;
f01014d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01014d5:	eb f4                	jmp    f01014cb <vsnprintf+0x57>

f01014d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01014d7:	f3 0f 1e fb          	endbr32 
f01014db:	55                   	push   %ebp
f01014dc:	89 e5                	mov    %esp,%ebp
f01014de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01014e1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01014e4:	50                   	push   %eax
f01014e5:	ff 75 10             	pushl  0x10(%ebp)
f01014e8:	ff 75 0c             	pushl  0xc(%ebp)
f01014eb:	ff 75 08             	pushl  0x8(%ebp)
f01014ee:	e8 81 ff ff ff       	call   f0101474 <vsnprintf>
	va_end(ap);

	return rc;
}
f01014f3:	c9                   	leave  
f01014f4:	c3                   	ret    

f01014f5 <__x86.get_pc_thunk.cx>:
f01014f5:	8b 0c 24             	mov    (%esp),%ecx
f01014f8:	c3                   	ret    

f01014f9 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014f9:	f3 0f 1e fb          	endbr32 
f01014fd:	55                   	push   %ebp
f01014fe:	89 e5                	mov    %esp,%ebp
f0101500:	57                   	push   %edi
f0101501:	56                   	push   %esi
f0101502:	53                   	push   %ebx
f0101503:	83 ec 1c             	sub    $0x1c,%esp
f0101506:	e8 c1 ec ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010150b:	81 c3 fd fd 00 00    	add    $0xfdfd,%ebx
f0101511:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101514:	85 c0                	test   %eax,%eax
f0101516:	74 13                	je     f010152b <readline+0x32>
		cprintf("%s", prompt);
f0101518:	83 ec 08             	sub    $0x8,%esp
f010151b:	50                   	push   %eax
f010151c:	8d 83 23 0c ff ff    	lea    -0xf3dd(%ebx),%eax
f0101522:	50                   	push   %eax
f0101523:	e8 84 f6 ff ff       	call   f0100bac <cprintf>
f0101528:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010152b:	83 ec 0c             	sub    $0xc,%esp
f010152e:	6a 00                	push   $0x0
f0101530:	e8 41 f2 ff ff       	call   f0100776 <iscons>
f0101535:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101538:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010153b:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0101540:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0101546:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101549:	eb 51                	jmp    f010159c <readline+0xa3>
			cprintf("read error: %e\n", c);
f010154b:	83 ec 08             	sub    $0x8,%esp
f010154e:	50                   	push   %eax
f010154f:	8d 83 e8 0d ff ff    	lea    -0xf218(%ebx),%eax
f0101555:	50                   	push   %eax
f0101556:	e8 51 f6 ff ff       	call   f0100bac <cprintf>
			return NULL;
f010155b:	83 c4 10             	add    $0x10,%esp
f010155e:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101563:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101566:	5b                   	pop    %ebx
f0101567:	5e                   	pop    %esi
f0101568:	5f                   	pop    %edi
f0101569:	5d                   	pop    %ebp
f010156a:	c3                   	ret    
			if (echoing)
f010156b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010156f:	75 05                	jne    f0101576 <readline+0x7d>
			i--;
f0101571:	83 ef 01             	sub    $0x1,%edi
f0101574:	eb 26                	jmp    f010159c <readline+0xa3>
				cputchar('\b');
f0101576:	83 ec 0c             	sub    $0xc,%esp
f0101579:	6a 08                	push   $0x8
f010157b:	e8 cd f1 ff ff       	call   f010074d <cputchar>
f0101580:	83 c4 10             	add    $0x10,%esp
f0101583:	eb ec                	jmp    f0101571 <readline+0x78>
				cputchar(c);
f0101585:	83 ec 0c             	sub    $0xc,%esp
f0101588:	56                   	push   %esi
f0101589:	e8 bf f1 ff ff       	call   f010074d <cputchar>
f010158e:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101591:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101594:	89 f0                	mov    %esi,%eax
f0101596:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0101599:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010159c:	e8 c0 f1 ff ff       	call   f0100761 <getchar>
f01015a1:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01015a3:	85 c0                	test   %eax,%eax
f01015a5:	78 a4                	js     f010154b <readline+0x52>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01015a7:	83 f8 08             	cmp    $0x8,%eax
f01015aa:	0f 94 c2             	sete   %dl
f01015ad:	83 f8 7f             	cmp    $0x7f,%eax
f01015b0:	0f 94 c0             	sete   %al
f01015b3:	08 c2                	or     %al,%dl
f01015b5:	74 04                	je     f01015bb <readline+0xc2>
f01015b7:	85 ff                	test   %edi,%edi
f01015b9:	7f b0                	jg     f010156b <readline+0x72>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01015bb:	83 fe 1f             	cmp    $0x1f,%esi
f01015be:	7e 10                	jle    f01015d0 <readline+0xd7>
f01015c0:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01015c6:	7f 08                	jg     f01015d0 <readline+0xd7>
			if (echoing)
f01015c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015cc:	74 c3                	je     f0101591 <readline+0x98>
f01015ce:	eb b5                	jmp    f0101585 <readline+0x8c>
		} else if (c == '\n' || c == '\r') {
f01015d0:	83 fe 0a             	cmp    $0xa,%esi
f01015d3:	74 05                	je     f01015da <readline+0xe1>
f01015d5:	83 fe 0d             	cmp    $0xd,%esi
f01015d8:	75 c2                	jne    f010159c <readline+0xa3>
			if (echoing)
f01015da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015de:	75 13                	jne    f01015f3 <readline+0xfa>
			buf[i] = 0;
f01015e0:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f01015e7:	00 
			return buf;
f01015e8:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f01015ee:	e9 70 ff ff ff       	jmp    f0101563 <readline+0x6a>
				cputchar('\n');
f01015f3:	83 ec 0c             	sub    $0xc,%esp
f01015f6:	6a 0a                	push   $0xa
f01015f8:	e8 50 f1 ff ff       	call   f010074d <cputchar>
f01015fd:	83 c4 10             	add    $0x10,%esp
f0101600:	eb de                	jmp    f01015e0 <readline+0xe7>

f0101602 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101602:	f3 0f 1e fb          	endbr32 
f0101606:	55                   	push   %ebp
f0101607:	89 e5                	mov    %esp,%ebp
f0101609:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010160c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101611:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101615:	74 05                	je     f010161c <strlen+0x1a>
		n++;
f0101617:	83 c0 01             	add    $0x1,%eax
f010161a:	eb f5                	jmp    f0101611 <strlen+0xf>
	return n;
}
f010161c:	5d                   	pop    %ebp
f010161d:	c3                   	ret    

f010161e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010161e:	f3 0f 1e fb          	endbr32 
f0101622:	55                   	push   %ebp
f0101623:	89 e5                	mov    %esp,%ebp
f0101625:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101628:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010162b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101630:	39 d0                	cmp    %edx,%eax
f0101632:	74 0d                	je     f0101641 <strnlen+0x23>
f0101634:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101638:	74 05                	je     f010163f <strnlen+0x21>
		n++;
f010163a:	83 c0 01             	add    $0x1,%eax
f010163d:	eb f1                	jmp    f0101630 <strnlen+0x12>
f010163f:	89 c2                	mov    %eax,%edx
	return n;
}
f0101641:	89 d0                	mov    %edx,%eax
f0101643:	5d                   	pop    %ebp
f0101644:	c3                   	ret    

f0101645 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101645:	f3 0f 1e fb          	endbr32 
f0101649:	55                   	push   %ebp
f010164a:	89 e5                	mov    %esp,%ebp
f010164c:	53                   	push   %ebx
f010164d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101650:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101653:	b8 00 00 00 00       	mov    $0x0,%eax
f0101658:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f010165c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f010165f:	83 c0 01             	add    $0x1,%eax
f0101662:	84 d2                	test   %dl,%dl
f0101664:	75 f2                	jne    f0101658 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0101666:	89 c8                	mov    %ecx,%eax
f0101668:	5b                   	pop    %ebx
f0101669:	5d                   	pop    %ebp
f010166a:	c3                   	ret    

f010166b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010166b:	f3 0f 1e fb          	endbr32 
f010166f:	55                   	push   %ebp
f0101670:	89 e5                	mov    %esp,%ebp
f0101672:	53                   	push   %ebx
f0101673:	83 ec 10             	sub    $0x10,%esp
f0101676:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101679:	53                   	push   %ebx
f010167a:	e8 83 ff ff ff       	call   f0101602 <strlen>
f010167f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0101682:	ff 75 0c             	pushl  0xc(%ebp)
f0101685:	01 d8                	add    %ebx,%eax
f0101687:	50                   	push   %eax
f0101688:	e8 b8 ff ff ff       	call   f0101645 <strcpy>
	return dst;
}
f010168d:	89 d8                	mov    %ebx,%eax
f010168f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101692:	c9                   	leave  
f0101693:	c3                   	ret    

f0101694 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101694:	f3 0f 1e fb          	endbr32 
f0101698:	55                   	push   %ebp
f0101699:	89 e5                	mov    %esp,%ebp
f010169b:	56                   	push   %esi
f010169c:	53                   	push   %ebx
f010169d:	8b 75 08             	mov    0x8(%ebp),%esi
f01016a0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016a3:	89 f3                	mov    %esi,%ebx
f01016a5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01016a8:	89 f0                	mov    %esi,%eax
f01016aa:	39 d8                	cmp    %ebx,%eax
f01016ac:	74 11                	je     f01016bf <strncpy+0x2b>
		*dst++ = *src;
f01016ae:	83 c0 01             	add    $0x1,%eax
f01016b1:	0f b6 0a             	movzbl (%edx),%ecx
f01016b4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01016b7:	80 f9 01             	cmp    $0x1,%cl
f01016ba:	83 da ff             	sbb    $0xffffffff,%edx
f01016bd:	eb eb                	jmp    f01016aa <strncpy+0x16>
	}
	return ret;
}
f01016bf:	89 f0                	mov    %esi,%eax
f01016c1:	5b                   	pop    %ebx
f01016c2:	5e                   	pop    %esi
f01016c3:	5d                   	pop    %ebp
f01016c4:	c3                   	ret    

f01016c5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01016c5:	f3 0f 1e fb          	endbr32 
f01016c9:	55                   	push   %ebp
f01016ca:	89 e5                	mov    %esp,%ebp
f01016cc:	56                   	push   %esi
f01016cd:	53                   	push   %ebx
f01016ce:	8b 75 08             	mov    0x8(%ebp),%esi
f01016d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01016d4:	8b 55 10             	mov    0x10(%ebp),%edx
f01016d7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01016d9:	85 d2                	test   %edx,%edx
f01016db:	74 21                	je     f01016fe <strlcpy+0x39>
f01016dd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01016e1:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f01016e3:	39 c2                	cmp    %eax,%edx
f01016e5:	74 14                	je     f01016fb <strlcpy+0x36>
f01016e7:	0f b6 19             	movzbl (%ecx),%ebx
f01016ea:	84 db                	test   %bl,%bl
f01016ec:	74 0b                	je     f01016f9 <strlcpy+0x34>
			*dst++ = *src++;
f01016ee:	83 c1 01             	add    $0x1,%ecx
f01016f1:	83 c2 01             	add    $0x1,%edx
f01016f4:	88 5a ff             	mov    %bl,-0x1(%edx)
f01016f7:	eb ea                	jmp    f01016e3 <strlcpy+0x1e>
f01016f9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01016fb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01016fe:	29 f0                	sub    %esi,%eax
}
f0101700:	5b                   	pop    %ebx
f0101701:	5e                   	pop    %esi
f0101702:	5d                   	pop    %ebp
f0101703:	c3                   	ret    

f0101704 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101704:	f3 0f 1e fb          	endbr32 
f0101708:	55                   	push   %ebp
f0101709:	89 e5                	mov    %esp,%ebp
f010170b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010170e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101711:	0f b6 01             	movzbl (%ecx),%eax
f0101714:	84 c0                	test   %al,%al
f0101716:	74 0c                	je     f0101724 <strcmp+0x20>
f0101718:	3a 02                	cmp    (%edx),%al
f010171a:	75 08                	jne    f0101724 <strcmp+0x20>
		p++, q++;
f010171c:	83 c1 01             	add    $0x1,%ecx
f010171f:	83 c2 01             	add    $0x1,%edx
f0101722:	eb ed                	jmp    f0101711 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101724:	0f b6 c0             	movzbl %al,%eax
f0101727:	0f b6 12             	movzbl (%edx),%edx
f010172a:	29 d0                	sub    %edx,%eax
}
f010172c:	5d                   	pop    %ebp
f010172d:	c3                   	ret    

f010172e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010172e:	f3 0f 1e fb          	endbr32 
f0101732:	55                   	push   %ebp
f0101733:	89 e5                	mov    %esp,%ebp
f0101735:	53                   	push   %ebx
f0101736:	8b 45 08             	mov    0x8(%ebp),%eax
f0101739:	8b 55 0c             	mov    0xc(%ebp),%edx
f010173c:	89 c3                	mov    %eax,%ebx
f010173e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101741:	eb 06                	jmp    f0101749 <strncmp+0x1b>
		n--, p++, q++;
f0101743:	83 c0 01             	add    $0x1,%eax
f0101746:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101749:	39 d8                	cmp    %ebx,%eax
f010174b:	74 16                	je     f0101763 <strncmp+0x35>
f010174d:	0f b6 08             	movzbl (%eax),%ecx
f0101750:	84 c9                	test   %cl,%cl
f0101752:	74 04                	je     f0101758 <strncmp+0x2a>
f0101754:	3a 0a                	cmp    (%edx),%cl
f0101756:	74 eb                	je     f0101743 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101758:	0f b6 00             	movzbl (%eax),%eax
f010175b:	0f b6 12             	movzbl (%edx),%edx
f010175e:	29 d0                	sub    %edx,%eax
}
f0101760:	5b                   	pop    %ebx
f0101761:	5d                   	pop    %ebp
f0101762:	c3                   	ret    
		return 0;
f0101763:	b8 00 00 00 00       	mov    $0x0,%eax
f0101768:	eb f6                	jmp    f0101760 <strncmp+0x32>

f010176a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010176a:	f3 0f 1e fb          	endbr32 
f010176e:	55                   	push   %ebp
f010176f:	89 e5                	mov    %esp,%ebp
f0101771:	8b 45 08             	mov    0x8(%ebp),%eax
f0101774:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101778:	0f b6 10             	movzbl (%eax),%edx
f010177b:	84 d2                	test   %dl,%dl
f010177d:	74 09                	je     f0101788 <strchr+0x1e>
		if (*s == c)
f010177f:	38 ca                	cmp    %cl,%dl
f0101781:	74 0a                	je     f010178d <strchr+0x23>
	for (; *s; s++)
f0101783:	83 c0 01             	add    $0x1,%eax
f0101786:	eb f0                	jmp    f0101778 <strchr+0xe>
			return (char *) s;
	return 0;
f0101788:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010178d:	5d                   	pop    %ebp
f010178e:	c3                   	ret    

f010178f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010178f:	f3 0f 1e fb          	endbr32 
f0101793:	55                   	push   %ebp
f0101794:	89 e5                	mov    %esp,%ebp
f0101796:	8b 45 08             	mov    0x8(%ebp),%eax
f0101799:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010179d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01017a0:	38 ca                	cmp    %cl,%dl
f01017a2:	74 09                	je     f01017ad <strfind+0x1e>
f01017a4:	84 d2                	test   %dl,%dl
f01017a6:	74 05                	je     f01017ad <strfind+0x1e>
	for (; *s; s++)
f01017a8:	83 c0 01             	add    $0x1,%eax
f01017ab:	eb f0                	jmp    f010179d <strfind+0xe>
			break;
	return (char *) s;
}
f01017ad:	5d                   	pop    %ebp
f01017ae:	c3                   	ret    

f01017af <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01017af:	f3 0f 1e fb          	endbr32 
f01017b3:	55                   	push   %ebp
f01017b4:	89 e5                	mov    %esp,%ebp
f01017b6:	57                   	push   %edi
f01017b7:	56                   	push   %esi
f01017b8:	53                   	push   %ebx
f01017b9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01017bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01017bf:	85 c9                	test   %ecx,%ecx
f01017c1:	74 31                	je     f01017f4 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01017c3:	89 f8                	mov    %edi,%eax
f01017c5:	09 c8                	or     %ecx,%eax
f01017c7:	a8 03                	test   $0x3,%al
f01017c9:	75 23                	jne    f01017ee <memset+0x3f>
		c &= 0xFF;
f01017cb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01017cf:	89 d3                	mov    %edx,%ebx
f01017d1:	c1 e3 08             	shl    $0x8,%ebx
f01017d4:	89 d0                	mov    %edx,%eax
f01017d6:	c1 e0 18             	shl    $0x18,%eax
f01017d9:	89 d6                	mov    %edx,%esi
f01017db:	c1 e6 10             	shl    $0x10,%esi
f01017de:	09 f0                	or     %esi,%eax
f01017e0:	09 c2                	or     %eax,%edx
f01017e2:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01017e4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01017e7:	89 d0                	mov    %edx,%eax
f01017e9:	fc                   	cld    
f01017ea:	f3 ab                	rep stos %eax,%es:(%edi)
f01017ec:	eb 06                	jmp    f01017f4 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01017ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017f1:	fc                   	cld    
f01017f2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01017f4:	89 f8                	mov    %edi,%eax
f01017f6:	5b                   	pop    %ebx
f01017f7:	5e                   	pop    %esi
f01017f8:	5f                   	pop    %edi
f01017f9:	5d                   	pop    %ebp
f01017fa:	c3                   	ret    

f01017fb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01017fb:	f3 0f 1e fb          	endbr32 
f01017ff:	55                   	push   %ebp
f0101800:	89 e5                	mov    %esp,%ebp
f0101802:	57                   	push   %edi
f0101803:	56                   	push   %esi
f0101804:	8b 45 08             	mov    0x8(%ebp),%eax
f0101807:	8b 75 0c             	mov    0xc(%ebp),%esi
f010180a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010180d:	39 c6                	cmp    %eax,%esi
f010180f:	73 32                	jae    f0101843 <memmove+0x48>
f0101811:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101814:	39 c2                	cmp    %eax,%edx
f0101816:	76 2b                	jbe    f0101843 <memmove+0x48>
		s += n;
		d += n;
f0101818:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010181b:	89 fe                	mov    %edi,%esi
f010181d:	09 ce                	or     %ecx,%esi
f010181f:	09 d6                	or     %edx,%esi
f0101821:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101827:	75 0e                	jne    f0101837 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101829:	83 ef 04             	sub    $0x4,%edi
f010182c:	8d 72 fc             	lea    -0x4(%edx),%esi
f010182f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101832:	fd                   	std    
f0101833:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101835:	eb 09                	jmp    f0101840 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101837:	83 ef 01             	sub    $0x1,%edi
f010183a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010183d:	fd                   	std    
f010183e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101840:	fc                   	cld    
f0101841:	eb 1a                	jmp    f010185d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101843:	89 c2                	mov    %eax,%edx
f0101845:	09 ca                	or     %ecx,%edx
f0101847:	09 f2                	or     %esi,%edx
f0101849:	f6 c2 03             	test   $0x3,%dl
f010184c:	75 0a                	jne    f0101858 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010184e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101851:	89 c7                	mov    %eax,%edi
f0101853:	fc                   	cld    
f0101854:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101856:	eb 05                	jmp    f010185d <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0101858:	89 c7                	mov    %eax,%edi
f010185a:	fc                   	cld    
f010185b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010185d:	5e                   	pop    %esi
f010185e:	5f                   	pop    %edi
f010185f:	5d                   	pop    %ebp
f0101860:	c3                   	ret    

f0101861 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101861:	f3 0f 1e fb          	endbr32 
f0101865:	55                   	push   %ebp
f0101866:	89 e5                	mov    %esp,%ebp
f0101868:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010186b:	ff 75 10             	pushl  0x10(%ebp)
f010186e:	ff 75 0c             	pushl  0xc(%ebp)
f0101871:	ff 75 08             	pushl  0x8(%ebp)
f0101874:	e8 82 ff ff ff       	call   f01017fb <memmove>
}
f0101879:	c9                   	leave  
f010187a:	c3                   	ret    

f010187b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010187b:	f3 0f 1e fb          	endbr32 
f010187f:	55                   	push   %ebp
f0101880:	89 e5                	mov    %esp,%ebp
f0101882:	56                   	push   %esi
f0101883:	53                   	push   %ebx
f0101884:	8b 45 08             	mov    0x8(%ebp),%eax
f0101887:	8b 55 0c             	mov    0xc(%ebp),%edx
f010188a:	89 c6                	mov    %eax,%esi
f010188c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010188f:	39 f0                	cmp    %esi,%eax
f0101891:	74 1c                	je     f01018af <memcmp+0x34>
		if (*s1 != *s2)
f0101893:	0f b6 08             	movzbl (%eax),%ecx
f0101896:	0f b6 1a             	movzbl (%edx),%ebx
f0101899:	38 d9                	cmp    %bl,%cl
f010189b:	75 08                	jne    f01018a5 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010189d:	83 c0 01             	add    $0x1,%eax
f01018a0:	83 c2 01             	add    $0x1,%edx
f01018a3:	eb ea                	jmp    f010188f <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f01018a5:	0f b6 c1             	movzbl %cl,%eax
f01018a8:	0f b6 db             	movzbl %bl,%ebx
f01018ab:	29 d8                	sub    %ebx,%eax
f01018ad:	eb 05                	jmp    f01018b4 <memcmp+0x39>
	}

	return 0;
f01018af:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01018b4:	5b                   	pop    %ebx
f01018b5:	5e                   	pop    %esi
f01018b6:	5d                   	pop    %ebp
f01018b7:	c3                   	ret    

f01018b8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01018b8:	f3 0f 1e fb          	endbr32 
f01018bc:	55                   	push   %ebp
f01018bd:	89 e5                	mov    %esp,%ebp
f01018bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01018c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01018c5:	89 c2                	mov    %eax,%edx
f01018c7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01018ca:	39 d0                	cmp    %edx,%eax
f01018cc:	73 09                	jae    f01018d7 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f01018ce:	38 08                	cmp    %cl,(%eax)
f01018d0:	74 05                	je     f01018d7 <memfind+0x1f>
	for (; s < ends; s++)
f01018d2:	83 c0 01             	add    $0x1,%eax
f01018d5:	eb f3                	jmp    f01018ca <memfind+0x12>
			break;
	return (void *) s;
}
f01018d7:	5d                   	pop    %ebp
f01018d8:	c3                   	ret    

f01018d9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01018d9:	f3 0f 1e fb          	endbr32 
f01018dd:	55                   	push   %ebp
f01018de:	89 e5                	mov    %esp,%ebp
f01018e0:	57                   	push   %edi
f01018e1:	56                   	push   %esi
f01018e2:	53                   	push   %ebx
f01018e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01018e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01018e9:	eb 03                	jmp    f01018ee <strtol+0x15>
		s++;
f01018eb:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01018ee:	0f b6 01             	movzbl (%ecx),%eax
f01018f1:	3c 20                	cmp    $0x20,%al
f01018f3:	74 f6                	je     f01018eb <strtol+0x12>
f01018f5:	3c 09                	cmp    $0x9,%al
f01018f7:	74 f2                	je     f01018eb <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f01018f9:	3c 2b                	cmp    $0x2b,%al
f01018fb:	74 2a                	je     f0101927 <strtol+0x4e>
	int neg = 0;
f01018fd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101902:	3c 2d                	cmp    $0x2d,%al
f0101904:	74 2b                	je     f0101931 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101906:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010190c:	75 0f                	jne    f010191d <strtol+0x44>
f010190e:	80 39 30             	cmpb   $0x30,(%ecx)
f0101911:	74 28                	je     f010193b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101913:	85 db                	test   %ebx,%ebx
f0101915:	b8 0a 00 00 00       	mov    $0xa,%eax
f010191a:	0f 44 d8             	cmove  %eax,%ebx
f010191d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101922:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101925:	eb 46                	jmp    f010196d <strtol+0x94>
		s++;
f0101927:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010192a:	bf 00 00 00 00       	mov    $0x0,%edi
f010192f:	eb d5                	jmp    f0101906 <strtol+0x2d>
		s++, neg = 1;
f0101931:	83 c1 01             	add    $0x1,%ecx
f0101934:	bf 01 00 00 00       	mov    $0x1,%edi
f0101939:	eb cb                	jmp    f0101906 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010193b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010193f:	74 0e                	je     f010194f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0101941:	85 db                	test   %ebx,%ebx
f0101943:	75 d8                	jne    f010191d <strtol+0x44>
		s++, base = 8;
f0101945:	83 c1 01             	add    $0x1,%ecx
f0101948:	bb 08 00 00 00       	mov    $0x8,%ebx
f010194d:	eb ce                	jmp    f010191d <strtol+0x44>
		s += 2, base = 16;
f010194f:	83 c1 02             	add    $0x2,%ecx
f0101952:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101957:	eb c4                	jmp    f010191d <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0101959:	0f be d2             	movsbl %dl,%edx
f010195c:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010195f:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101962:	7d 3a                	jge    f010199e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0101964:	83 c1 01             	add    $0x1,%ecx
f0101967:	0f af 45 10          	imul   0x10(%ebp),%eax
f010196b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010196d:	0f b6 11             	movzbl (%ecx),%edx
f0101970:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101973:	89 f3                	mov    %esi,%ebx
f0101975:	80 fb 09             	cmp    $0x9,%bl
f0101978:	76 df                	jbe    f0101959 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f010197a:	8d 72 9f             	lea    -0x61(%edx),%esi
f010197d:	89 f3                	mov    %esi,%ebx
f010197f:	80 fb 19             	cmp    $0x19,%bl
f0101982:	77 08                	ja     f010198c <strtol+0xb3>
			dig = *s - 'a' + 10;
f0101984:	0f be d2             	movsbl %dl,%edx
f0101987:	83 ea 57             	sub    $0x57,%edx
f010198a:	eb d3                	jmp    f010195f <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f010198c:	8d 72 bf             	lea    -0x41(%edx),%esi
f010198f:	89 f3                	mov    %esi,%ebx
f0101991:	80 fb 19             	cmp    $0x19,%bl
f0101994:	77 08                	ja     f010199e <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101996:	0f be d2             	movsbl %dl,%edx
f0101999:	83 ea 37             	sub    $0x37,%edx
f010199c:	eb c1                	jmp    f010195f <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f010199e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01019a2:	74 05                	je     f01019a9 <strtol+0xd0>
		*endptr = (char *) s;
f01019a4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01019a7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01019a9:	89 c2                	mov    %eax,%edx
f01019ab:	f7 da                	neg    %edx
f01019ad:	85 ff                	test   %edi,%edi
f01019af:	0f 45 c2             	cmovne %edx,%eax
}
f01019b2:	5b                   	pop    %ebx
f01019b3:	5e                   	pop    %esi
f01019b4:	5f                   	pop    %edi
f01019b5:	5d                   	pop    %ebp
f01019b6:	c3                   	ret    
