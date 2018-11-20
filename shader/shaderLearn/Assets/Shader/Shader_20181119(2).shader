Shader "ShaProShader/sha_20181119(2)" {
	Properties{
		//调制色_Color和主要纹理_MainTex将会相乘，得到调制后的颜色
		_Color("The Main Color", Color) = (1,1,1,1)
		_MainTex("Base Picture", 2D) = "white"{}
		//两张图默认都是白色（前面的数据结构是颜色，后面的是二维图像）
	}

		//之前也说过，这是一个处理子程序（一个Pass）
		SubShader{
		//渲染类型是不透明
		Tags{ "RenderType" = "Opaque" }
		//当机器的能力超过200时，会执行这个SubShader
		LOD 200

		CGPROGRAM
		//pragma surface 处理函数 光照模型
		/*其中这里的光照模型是Lambert模型，也就是环境光+散射光+反射高光+放射光*/
#pragma surface surf Lambert

		//还记得吗？同名变量，注意对应关系：Color对应fixed4，2D对应sampler2D
		sampler2D _MainTex;
	fixed4 _Color;

	//输入结构体一定要命名为Input，自己规定其输入，注意纹理坐标的写法一定是纹理贴图变量名前面加uv
	struct Input {
		float2 uv_MainTex;
	};

	//surf函数的输入输出是定死的，即Input和inout SurfaceOutput，后者是输出
	void surf(Input IN, inout SurfaceOutput o)
	{
		//非常简单，就是用tex2D(贴图，纹理坐标)取出纹理上的一点，然后和Color相乘调制即可得到结果
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex)*_Color;
		//Albedo是主颜色的意思（本质是一个用来相乘的系数，当外界光线找到此表面上时，反射的光线 = 入射光线 * Albedo）
		o.Albedo = c.rgb;
		//获得其透明度Alpha
		o.Alpha = c.a;
		/*追加说明：SurfaceOutput这个固定好的结构中，有以下几个值：
		struct SurfaceOutput {
		half3 Albedo;     //像素的颜色
		half3 Normal;     //像素的法向值
		half3 Emission;   //像素的发散颜色
		half Specular;    //像素的镜面高光
		half Gloss;       //像素的发光强度
		half Alpha;       //像素的透明度
		};
		*/
	}
	ENDCG
	}
		//Fallback暗藏乾坤，表示将此回滚全部插入到本代码中！（我凭什么这么说：http://www.ceeger.com/forum/read.php?tid=31958）
		//也就是说"Legacy Shaders/VertexLit"会完全插入到这里
		Fallback "Legacy Shaders/VertexLit"
}