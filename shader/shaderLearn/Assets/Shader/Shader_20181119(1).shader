//首行声明了一个Shader，命名为Shad0，存放在路径Custom下（这个路径在哪里不是重点，它归类在自定义中），看上去是不是挺像结构体的声明
Shader "ShaProShader/sha_20181119(1)" {

	/*
	在讲第一块内容之前，请先去了解一下UV纹理。简单来说：A是一张图片（称A为纹理），B是一张坐标信息（称B为UV），用B来取A就是纹理贴图的精髓了，举个简单的例子：
	A的色彩如下：
	红 黄
	蓝 绿

	B的坐标信息如下：
	（0,0） （1,1）
	（1,1） （0,1）

	那么取出来得到的纹理贴图就是：
	红 绿
	绿 黄

	这样子，是不是很无聊？当这上面的点数达到很大的量级时，就很有意义了。
	没完，你还需要了解镜面高光和金属度的概念，自行百度（或者先跳过这个知识点继续往下看）。


	补充：
	UV的概念是坐标索引，用坐标索引从纹理中采出颜色单元。
	假如A是一副2*2的纹理图，颜色为
	红 黄
	蓝 绿
	B是UV，具体为：
	(0,0) (1,1)
	(1,1) (0,1)
	对于A图（左上角为原点，U轴假设是纵轴，V轴假设是横轴）来说，(0,0)坐标取出的颜色是红色，(1,1)坐标取出的颜色是绿色，(0,1)为蓝色。所以以B取A得到的实际效果就是：
	红 绿
	绿 黄
	*/

	/*第一块：属性声明*/
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
		/*用_XX的声明方法来声明的变量就是称为属性了，这一句的语法是：
		_XXX (展示名， 数据类型) = 默认值

		展示名是在Unity中可见的名称，Color其实是一种数据类型（就像int那样，只是后者很简单，是基本数据类型）。
		数据类型有哪些（参考上述博文）：

		常用属性类型有：

		（1） Color - 一种颜色，由RGBA（红绿蓝和透明度）四个量来定义；
		（2） 2D - 一张2的阶数大小（256，512之类）的贴图。这张贴图将在采样后被转为对应基于模型UV的每个像素的颜色，最终被显示出来；
		（3）Rect - 一个非2阶数大小的贴图；
		（4）Cube - 即Cube map texture（立方体纹理），简单说就是6张有联系的2D贴图的组合，主要用来做反射效果（比如天空盒和动态反射），也会被转换为对应点的采样；
		（5）Range(min, max) - 一个介于最小值和最大值之间的浮点数，一般用来当作调整Shader某些特性的参数（比如透明度渲染的截止值可以是从0至1的值等）；
		（6）Float - 任意一个浮点数；
		（7）Vector - 一个四维数；

		请看默认值（1,1,1,1），形如（g,b,a,A），其中的透明度A为0时，表示透明，为1时，表示完全不透明，所以应该称之为不透明度。
		*/

        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		/*这里表示一张图片，这张图片在这里仅仅用空白来表示*/
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
		/*高光设置为.5*/
        _Metallic ("Metallic", Range(0,1)) = 0.0
		/*金属度*/
    }

	/*第二块内容：什么是SubShader，如果你用过虚幻4，就能够很容易理解，其实SubShader对应了UE4中的材质表达式。
	UE4中的材质表达式或者Unity中的shader本质是什么？简单来说就是将图片通过处理得到另一张图片（比如用图片+UV信息 -> 纹理贴图的过程）。
	SubShader其实就是定义了图片处理过程*/
    SubShader {
		/*  Tags规定了混合模型。什么是混合模型？请看下面的附图1，当然，混合模型是UE4中的概念。
			这里贴一段相比Unity更为正确的解释：
			Background - 最早被调用的渲染，用来渲染天空盒或者背景
			Geometry - 这是默认值，用来渲染非透明物体（普通情况下，场景中的绝大多数物体应该是非透明的）
			AlphaTest - 用来渲染经过Alpha Test的像素，单独为AlphaTest设定一个Queue是出于对效率的考虑
			Transparent - 以从后往前的顺序渲染透明物体
			Overlay - 用来渲染叠加的效果，是渲染的最后阶段（比如镜头光晕等特效）
		*/

        Tags { "RenderType"="Opaque" }

		/*LOD表示细节呈现级别（也即是画质，即粗糙/细腻程度）
		当机器很差的时候，差到其评估值小于200时，本材质无效（也就是本shader罢工）。当机器的性能不错，大于200时，本shader继续工作。就是这么有个性。
		别气馁，下面的内容是最重要的。
		*/
        LOD 200
        
		/*这是一个标记：CGPROGRAM，表示这是一段computer graph编程*/
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
		/*请看这个奇怪的函数声明：
		#pragma surface表面着色器 surffunction着色器的代码（在本例子中就是下面的surf） lightModel（光照模型，这个概念先跳过） [可选参数]
		*/
        #pragma target 3.0

		/*
		用笔者的话来说：sampler2D就是一张图片……（还记得吗，就是上文说的A图片）
		贴一段介绍：
		接下来一句sampler2D _MainTex;，sampler2D是个啥？
		其实在CG中，sampler2D就是和texture所绑定的一个数据容器接口。
		等等..这个说法还是太复杂了，简单理解的话，所谓加载以后的texture（贴图）说白了不过是一块内存存储的，
		使用了RGB（也许还有A）通道，且每个通道8bits的数据。而具体地想知道像素与坐标的对应关系，以及获取这些数据，
		我们总不能一次一次去自己计算内存地址或者偏移，因此可以通过sampler2D来对贴图进行操作。
		更简单地理解，sampler2D就是GLSL中的2D贴图的类型，相应的，
		还有sampler1D，sampler3D，samplerCube等等格式。

		解释通了sampler2D是什么之后，
		还需要解释下为什么在这里需要一句对_MainTex的声明，
		之前我们不是已经在Properties里声明过它是贴图了么。
		答案是我们用来实例的这个shader其实是由两个相对独立的块组成的，
		外层的属性声明，回滚等等是Unity可以直接使用和编译的ShaderLab；
		而现在我们是在CGPROGRAM...ENDCG这样一个代码块中，这是一段CG程序。
		对于这段CG程序，要想访问在Properties中所定义的变量的话，必须使用和之前变量相同的名字进行声明！【注意这里！！！】
		于是其实sampler2D _MainTex;做的事情就是再次声明并链接了_MainTex，
		使得接下来的CG程序能够使用这个变量。*/
        sampler2D _MainTex;

		/*这是一个非常简单的结构体，称为Input，其中有一个float2数据类型，这是一个二维float矢量，也就是（a,b）这样的。*/
        struct Input {
            float2 uv_MainTex;
        };

		/*在坚持一下，这里还有几个变量：half类型的两个，fixed4类型的一个，
		half类型表示半精度浮点数，计算性能好但是精度低，和float和double是同类型的浮点数；
		fixed4不详，但是大意是四维的矢量*/

        half _Glossiness;  //必须使用和之前变量相同的名字进行声明！【注意这里！！！】
        half _Metallic;    //必须使用和之前变量相同的名字进行声明！【注意这里！！！】
        fixed4 _Color;     //必须使用和之前变量相同的名字进行声明！【注意这里！！！】

		/*核心的处理函数：surf，输入一张二维浮点信息，也即是上面的uv_MainTex，
		输出一个o表示材质（inout像c++里面的按照引入传入，虽说没有返回，但是也有信息传出的效果）*/
        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			/*看这里：tex2D就是前面说的"利用UV去取图片获得纹理贴图"的做法，然后再乘以_Color，
			这里用到了乘法的颜色算法，自己体会（这个_Color默认值为1，1，1，1，所以默认下不影响）
			笔者到这里可以知道：fixed4表示一种四维矢量（用来表示颜色就挺合适的。此外，它是定点型小数而非浮点型小数）
			*/

            o.Albedo = c.rgb;
			/* inout SurfaceOutputStandard o
			这个结构有哪些包含的变量呢：
			struct SurfaceOutput {
			half3 Albedo;     //像素的颜色
			half3 Normal;     //像素的法向值
			half3 Emission;   //像素的发散颜色
			half Specular;    //像素的镜面高光
			half Gloss;       //像素的发光强度
			half Alpha;       //像素的透明度
			};
			*/

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
			/*结束CG编码*/
    }
    FallBack "Diffuse"
}